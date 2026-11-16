from __future__ import annotations

import json
import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
REGISTRY_PATH = ROOT / "research" / "source-registry.json"
FETCH_HELPER = ROOT / "tools" / "research" / "fetch-reference.sh"


class ResearchRegistryTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        with REGISTRY_PATH.open("r", encoding="utf-8") as handle:
            cls.registry = json.load(handle)

    def test_registry_has_expected_top_level_contract(self) -> None:
        self.assertEqual(self.registry.get("schema_version"), 1)
        self.assertEqual(
            self.registry.get("atomic_z_baseline", {}).get("repository"),
            "metsam-mastem/Atomic-Z-Customi-Z",
        )
        self.assertEqual(
            self.registry.get("atomic_z_baseline", {}).get("canonical_editable_state"),
            "BuildDocument",
        )
        self.assertEqual(
            self.registry.get("atomic_z_baseline", {}).get("product_runtime"),
            "Godot 4 / GDScript",
        )

    def test_source_ids_are_unique_and_records_are_well_formed(self) -> None:
        sources = self.registry.get("sources")
        self.assertIsInstance(sources, list)
        self.assertGreaterEqual(len(sources), 1)
        ids: list[str] = []
        for source in sources:
            self.assertIsInstance(source, dict)
            source_id = source.get("id")
            self.assertIsInstance(source_id, str)
            self.assertRegex(source_id, r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
            ids.append(source_id)
            self.assertTrue(source.get("name"))
            self.assertTrue(source.get("status"))
            self.assertIsInstance(source.get("licence"), dict)
            self.assertTrue(source["licence"].get("spdx"))
            revision = source.get("revision")
            self.assertIsInstance(revision, dict)
            if revision.get("pinned") is True:
                commit = revision.get("commit")
                self.assertIsInstance(commit, str)
                self.assertRegex(commit, r"^[0-9a-f]{40}$", msg=source_id)
            elif revision.get("commit"):
                self.fail(f"{source_id}: commit is present but revision is not marked pinned")
        self.assertEqual(len(ids), len(set(ids)), "source IDs must be unique")

    def test_reference_fetch_helper_is_present_and_has_safe_shell_header(self) -> None:
        self.assertTrue(FETCH_HELPER.is_file())
        text = FETCH_HELPER.read_text(encoding="utf-8")
        self.assertTrue(text.startswith("#!/usr/bin/env bash"))
        self.assertIn("set -euo pipefail", text)
        self.assertIn(".research-cache", text)
        self.assertIn("Unknown, unpinned or rights-unreviewed source ID", text)


if __name__ == "__main__":
    unittest.main()
