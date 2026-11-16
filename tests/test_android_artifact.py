import tempfile
import unittest
import zipfile
from pathlib import Path
from scripts.verify_android_artifact import ArtifactError, inspect_apk

class AndroidArtifactTests(unittest.TestCase):
    def make_apk(self, entries):
        temp_dir = tempfile.TemporaryDirectory()
        self.addCleanup(temp_dir.cleanup)
        apk = Path(temp_dir.name) / "fixture.apk"
        with zipfile.ZipFile(apk, "w") as archive:
            for name, payload in entries.items():
                archive.writestr(name, payload)
        return apk

    def valid_entries(self):
        return {
            "AndroidManifest.xml": b"manifest",
            "assets/project.binary": b"godot-project",
            "lib/arm64-v8a/libgodot_android.so": b"godot-runtime",
            "classes.dex": b"dex",
            "assets/.godot/exported/123/main.scn": b"scene",
            "META-INF/DEBUG.RSA": b"signature",
        }

    def test_accepts_complete_godot_arm64_apk(self):
        report = inspect_apk(self.make_apk(self.valid_entries()))
        self.assertEqual(report["structure"], "PASS")
        self.assertTrue(report["arm64_godot_runtime"])
        self.assertTrue(report["godot_project_payload"])
        self.assertTrue(report["signature_block_present"])

    def test_rejects_non_apk_file(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "not-an-apk.apk"
            path.write_text("not a zip", encoding="utf-8")
            with self.assertRaisesRegex(ArtifactError, "not a valid ZIP/APK"):
                inspect_apk(path)

    def test_rejects_missing_godot_project_payload(self):
        entries = self.valid_entries()
        del entries["assets/project.binary"]
        with self.assertRaisesRegex(ArtifactError, "assets/project.binary"):
            inspect_apk(self.make_apk(entries))

    def test_rejects_missing_arm64_runtime(self):
        entries = self.valid_entries()
        del entries["lib/arm64-v8a/libgodot_android.so"]
        with self.assertRaisesRegex(ArtifactError, "lib/arm64-v8a/libgodot_android.so"):
            inspect_apk(self.make_apk(entries))

    def test_rejects_apk_without_scene_payload(self):
        entries = self.valid_entries()
        del entries["assets/.godot/exported/123/main.scn"]
        with self.assertRaisesRegex(ArtifactError, "scene payload"):
            inspect_apk(self.make_apk(entries))

if __name__ == "__main__":
    unittest.main()
