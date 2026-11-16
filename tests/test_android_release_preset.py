import json
import tempfile
import unittest
from pathlib import Path

from scripts.configure_android_release_preset import (
    ReleasePresetError,
    configure_release_preset,
)


class AndroidReleasePresetTests(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp_dir.cleanup)
        self.root = Path(self.temp_dir.name)
        self.source = self.root / "export_presets.cfg"
        self.destination = self.root / "isolated" / "export_presets.cfg"
        self.keystore = self.root / "release.keystore"
        self.keystore.write_bytes(b"test-keystore")

    def source_text(self):
        return """config_version=5

[preset.1.options]
architectures/arm64-v8a=true
keystore/release=""
keystore/release_user=""
keystore/release_password=""
package/signed=true
"""

    def test_injects_signing_values_only_into_isolated_copy(self):
        original = self.source_text()
        self.source.write_text(original, encoding="utf-8")
        configure_release_preset(
            self.source, self.destination, str(self.keystore),
            "release-alias", 'p@ss"word\\value'
        )
        self.assertEqual(self.source.read_text(encoding="utf-8"), original)
        configured = self.destination.read_text(encoding="utf-8")
        self.assertIn("keystore/release=" + json.dumps(str(self.keystore.resolve())), configured)
        self.assertIn("keystore/release_user=" + json.dumps("release-alias"), configured)
        self.assertIn("keystore/release_password=" + json.dumps('p@ss"word\\value'), configured)
        self.assertIn("architectures/arm64-v8a=true", configured)
        self.assertEqual(self.destination.stat().st_mode & 0o777, 0o600)

    def test_rejects_missing_keystore_file(self):
        self.source.write_text(self.source_text(), encoding="utf-8")
        with self.assertRaisesRegex(ReleasePresetError, "keystore file"):
            configure_release_preset(
                self.source, self.destination, str(self.root / "missing.keystore"),
                "alias", "password"
            )

    def test_rejects_missing_release_options_section(self):
        self.source.write_text("[preset.1]\nname=Android Release\n", encoding="utf-8")
        with self.assertRaisesRegex(ReleasePresetError, "preset.1.options"):
            configure_release_preset(
                self.source, self.destination, str(self.keystore), "alias", "password"
            )

    def test_rejects_missing_signing_key(self):
        self.source.write_text(
            "[preset.1.options]\nkeystore/release=\"\"\nkeystore/release_user=\"\"\n",
            encoding="utf-8",
        )
        with self.assertRaisesRegex(ReleasePresetError, "keystore/release_password"):
            configure_release_preset(
                self.source, self.destination, str(self.keystore), "alias", "password"
            )

    def test_rejects_empty_credentials(self):
        self.source.write_text(self.source_text(), encoding="utf-8")
        with self.assertRaisesRegex(ReleasePresetError, "non-empty"):
            configure_release_preset(
                self.source, self.destination, str(self.keystore), "", "password"
            )

    def test_refuses_to_overwrite_the_source_preset(self):
        self.source.write_text(self.source_text(), encoding="utf-8")
        with self.assertRaisesRegex(ReleasePresetError, "separate temporary"):
            configure_release_preset(
                self.source, self.source, str(self.keystore), "alias", "password"
            )


if __name__ == "__main__":
    unittest.main()
