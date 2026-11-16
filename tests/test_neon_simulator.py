import json
import unittest
from pathlib import Path

from neon_simulator import load_config, resolve_segments


ROOT = Path(__file__).resolve().parents[1]


class NeonSimulatorTests(unittest.TestCase):
    def test_config_preserves_requested_bike_and_skin(self):
        config = load_config(ROOT / "neon_skin_config.json")
        self.assertEqual(config["bike_model"], "Kawasaki Ninja ZX-25R")
        self.assertEqual(config["skin_name"], "Neon Cyberpunk")
        self.assertEqual(config["colors"]["primary"], "#00FFCC")
        self.assertEqual(config["colors"]["secondary"], "#FF00FF")
        self.assertEqual(config["colors"]["glow_intensity"], 0.8)

    def test_segments_resolve_named_colors_and_keep_points(self):
        config = load_config(ROOT / "neon_skin_config.json")
        segments = resolve_segments(config)
        self.assertEqual([item["id"] for item in segments],
                         ["tail_underglow", "tank_accent", "lower_fairing"])
        self.assertEqual(segments[0]["color"], "#00FFCC")
        self.assertEqual(segments[1]["color"], "#FF00FF")
        self.assertEqual(segments[2]["points"],
                         [[100, 450], [250, 420], [400, 430], [500, 480]])

    def test_invalid_color_reference_is_rejected(self):
        config = load_config(ROOT / "neon_skin_config.json")
        config["line_segments"][0]["color"] = "unknown"
        with self.assertRaises(ValueError):
            resolve_segments(config)

    def test_invalid_glow_range_is_rejected(self):
        config = load_config(ROOT / "neon_skin_config.json")
        config["colors"]["glow_intensity"] = 1.5
        with self.assertRaises(ValueError):
            resolve_segments(config)


if __name__ == "__main__":
    unittest.main()
