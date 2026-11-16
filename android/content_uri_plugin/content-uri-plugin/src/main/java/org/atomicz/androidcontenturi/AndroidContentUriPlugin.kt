package org.atomicz.androidcontenturi

import android.app.Activity
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.OpenableColumns
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream
import java.util.concurrent.Executors

private const val REQUEST_OPEN_GLB = 0x00ACF000
private const val MAX_IMPORT_BYTES = 128L * 1024L * 1024L
private const val BUFFER_SIZE = 512 * 1024

/**
 * Narrow Android Storage Access Framework bridge for importing a single GLB
 * into the app's private user:// storage. Does not request broad storage access.
 *
 * API shape is based on the MIT-licensed GodotAndroidContentUri project by FFF27,
 * with bounded streaming and safe destination validation implemented locally.
 */
class AndroidContentUriPlugin(godot: Godot) : GodotPlugin(godot) {
    private val mainHandler = Handler(Looper.getMainLooper())
    private val transferExecutor = Executors.newSingleThreadExecutor()

    override fun getPluginName(): String = "AndroidContentUri"

    override fun getPluginMethods(): List<String> = listOf(
        "launchFilePickerOpenFile",
        "importFile"
    )

    override fun getPluginSignals(): Set<SignalInfo> = setOf(
        SignalInfo("file_selected", String::class.java, String::class.java),
        SignalInfo("file_picker_canceled"),
        SignalInfo("file_picker_error", String::class.java),
        SignalInfo("file_imported", String::class.java),
        SignalInfo("file_transfer_error", String::class.java)
    )

    fun launchFilePickerOpenFile(mimeType: String = "*/*") {
        try {
            val currentActivity = activity
            if (currentActivity == null) {
                emitSignal("file_picker_error", "Android activity is not available.")
                return
            }
            val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                addCategory(Intent.CATEGORY_OPENABLE)
                type = mimeType
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            currentActivity.startActivityForResult(intent, REQUEST_OPEN_GLB)
        } catch (error: Exception) {
            emitSignal("file_picker_error", error.message ?: error.javaClass.simpleName)
        }
    }

    /**
     * Returns true when the copy job was accepted. Completion is reported by
     * file_imported(localPath); failures are reported by file_transfer_error.
     */
    fun importFile(contentUri: String, localFile: String): Boolean {
        val uri = try {
            Uri.parse(contentUri)
        } catch (error: Exception) {
            emitSignal("file_transfer_error", "Invalid content URI.")
            return false
        }
        if (uri.scheme != "content") {
            emitSignal("file_transfer_error", "Only Android content:// document URIs are accepted.")
            return false
        }

        val destination = resolvePrivateUserFile(localFile)
        if (destination == null) {
            emitSignal("file_transfer_error", "Destination must be a safe user:// path.")
            return false
        }

        return try {
            transferExecutor.execute {
                copyDocument(uri, destination, localFile)
            }
            true
        } catch (error: Exception) {
            emitSignal("file_transfer_error", error.message ?: "Could not queue the document import.")
            false
        }
    }

    private fun copyDocument(uri: Uri, destination: File, godotPath: String) {
        var input: InputStream? = null
        var output: FileOutputStream? = null
        var success = false
        try {
            val resolver = activity?.applicationContext?.contentResolver
                ?: throw IllegalStateException("Android ContentResolver is unavailable.")
            input = resolver.openInputStream(uri)
                ?: throw IllegalStateException("The selected document could not be opened.")

            val parent = destination.parentFile
                ?: throw IllegalStateException("Import destination has no parent directory.")
            if (!parent.exists() && !parent.mkdirs()) {
                throw IllegalStateException("Could not create the private import directory.")
            }
            output = FileOutputStream(destination, false)

            val buffer = ByteArray(BUFFER_SIZE)
            var totalBytes = 0L
            while (true) {
                val count = input.read(buffer)
                if (count < 0) break
                if (count == 0) continue
                totalBytes += count.toLong()
                if (totalBytes > MAX_IMPORT_BYTES) {
                    throw IllegalArgumentException("GLB exceeds the 128 MiB import limit.")
                }
                output.write(buffer, 0, count)
            }
            output.flush()
            output.fd.sync()
            if (totalBytes < 20L) {
                throw IllegalArgumentException("Selected GLB is empty or too small.")
            }
            if (destination.length() != totalBytes) {
                throw IllegalStateException("Copied byte count does not match the source stream.")
            }

            success = true
            mainHandler.post { emitSignal("file_imported", godotPath) }
        } catch (error: Exception) {
            mainHandler.post {
                emitSignal("file_transfer_error", error.message ?: error.javaClass.simpleName)
            }
        } finally {
            try { output?.close() } catch (_: Exception) {}
            try { input?.close() } catch (_: Exception) {}
            if (!success && destination.exists()) {
                destination.delete()
            }
        }
    }

    private fun resolvePrivateUserFile(godotPath: String): File? {
        if (!godotPath.startsWith("user://") || godotPath.length <= 7) return null
        val relative = godotPath.substring(7)
        val segments = relative.split('/')
        if (segments.any { it.isBlank() || it == "." || it == ".." }) return null

        return try {
            val root = activity?.filesDir?.canonicalFile ?: return null
            val target = File(root, relative).canonicalFile
            if (!target.path.startsWith(root.path + File.separator)) null else target
        } catch (_: Exception) {
            null
        }
    }

    override fun onMainActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != REQUEST_OPEN_GLB) return
        if (resultCode == Activity.RESULT_CANCELED) {
            emitSignal("file_picker_canceled")
            return
        }
        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            emitSignal("file_picker_error", "Android document picker did not return a document.")
            return
        }

        val selectedUri = data.data!!
        val displayName = queryDisplayName(selectedUri)
        emitSignal("file_selected", selectedUri.toString(), displayName)
    }

    private fun queryDisplayName(uri: Uri): String {
        var cursor: Cursor? = null
        return try {
            val resolver = activity?.applicationContext?.contentResolver ?: return ""
            cursor = resolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)
            if (cursor != null && cursor.moveToFirst()) {
                val index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (index >= 0) cursor.getString(index) ?: "" else ""
            } else {
                ""
            }
        } catch (_: Exception) {
            ""
        } finally {
            cursor?.close()
        }
    }
}
