"""Tkinter preview tool for the Atomic Z Neon Cyberpunk skin.

Run from the repository root: python neon_simulator.py
The preview is a 2D concept overlay, not a 3D Kawasaki CAD renderer.
"""
from __future__ import annotations

import copy
import json
from pathlib import Path
import tkinter as tk
from tkinter import colorchooser, messagebox, ttk
from typing import Any

CONFIG_PATH = Path(__file__).with_name("neon_skin_config.json")
CANVAS_WIDTH = 760
CANVAS_HEIGHT = 560
PADDING = 48


def load_config(path: str | Path = CONFIG_PATH) -> dict[str, Any]:
    """Load and validate the JSON skin document."""
    with Path(path).open("r", encoding="utf-8") as handle:
        config = json.load(handle)
    required = {"bike_model", "skin_name", "colors", "line_segments"}
    if not required.issubset(config):
        raise ValueError(f"Missing config keys: {sorted(required - set(config))}")
    resolve_segments(config)  # validate all color references and geometry
    return config


def resolve_segments(config: dict[str, Any]) -> list[dict[str, Any]]:
    """Return normalized segment data with named colors resolved to hex."""
    colors = config.get("colors", {})
    primary = colors.get("primary")
    secondary = colors.get("secondary")
    glow = colors.get("glow_intensity")
    if not isinstance(primary, str) or not isinstance(secondary, str):
        raise ValueError("primary and secondary colors must be hex strings")
    if not isinstance(glow, (int, float)) or not 0.0 <= float(glow) <= 1.0:
        raise ValueError("glow_intensity must be between 0 and 1")

    resolved = []
    for segment in config.get("line_segments", []):
        points = segment.get("points")
        if not isinstance(points, list) or len(points) < 2:
            raise ValueError(f"Segment {segment.get('id')} needs at least two points")
        if any(not isinstance(point, list) or len(point) != 2 or
               not all(isinstance(value, (int, float)) for value in point)
               for point in points):
            raise ValueError(f"Segment {segment.get('id')} has invalid points")
        width = segment.get("width")
        if not isinstance(width, (int, float)) or width <= 0:
            raise ValueError(f"Segment {segment.get('id')} has invalid width")
        color_key = segment.get("color")
        if color_key not in ("primary", "secondary"):
            raise ValueError(f"Unknown color reference: {color_key}")
        resolved.append({
            **segment,
            "points": points,
            "width": float(width),
            "color": colors[color_key],
        })
    return resolved


class NeonSimulator:
    def __init__(self, root: tk.Tk, config_path: Path = CONFIG_PATH) -> None:
        self.root = root
        self.config_path = config_path
        self.config = load_config(config_path)
        self._original = copy.deepcopy(self.config)
        self.visible = {item["id"]: True for item in resolve_segments(self.config)}
        self._build_ui()
        self.redraw()

    def _build_ui(self) -> None:
        self.root.title("Atomic Z | Neon Skin Simulator")
        self.root.geometry("1120x700")
        self.root.minsize(900, 620)
        self.root.configure(bg="#0b1018")

        style = ttk.Style()
        style.theme_use("clam")
        style.configure("TFrame", background="#0b1018")
        style.configure("TLabel", background="#0b1018", foreground="#dce8f2")
        style.configure("TButton", padding=7)
        style.configure("Header.TLabel", font=("Segoe UI", 16, "bold"),
                        foreground="#00ffcc")
        style.configure("Sub.TLabel", foreground="#8da2b5")

        shell = ttk.Frame(self.root, padding=16)
        shell.pack(fill="both", expand=True)
        header = ttk.Frame(shell)
        header.pack(fill="x", pady=(0, 12))
        ttk.Label(header, text="ATOMIC Z / NEON SKIN LAB",
                  style="Header.TLabel").pack(anchor="w")
        ttk.Label(header, text=f"{self.config['bike_model']}  •  {self.config['skin_name']}",
                  style="Sub.TLabel").pack(anchor="w", pady=(4, 0))

        body = ttk.Frame(shell)
        body.pack(fill="both", expand=True)
        self.canvas = tk.Canvas(body, width=CANVAS_WIDTH, height=CANVAS_HEIGHT,
                                bg="#111b28", highlightthickness=1,
                                highlightbackground="#26394b")
        self.canvas.pack(side="left", fill="both", expand=True)

        panel = ttk.Frame(body, width=250, padding=(16, 8))
        panel.pack(side="right", fill="y")
        panel.pack_propagate(False)
        ttk.Label(panel, text="SKIN LAYERS", style="Header.TLabel").pack(anchor="w")
        self.layer_vars: dict[str, tk.BooleanVar] = {}
        for segment in resolve_segments(self.config):
            var = tk.BooleanVar(value=True)
            self.layer_vars[segment["id"]] = var
            ttk.Checkbutton(panel, text=segment["id"].replace("_", " ").title(),
                            variable=var, command=self._sync_layers).pack(anchor="w", pady=5)

        ttk.Separator(panel).pack(fill="x", pady=14)
        ttk.Label(panel, text="GLOW INTENSITY").pack(anchor="w")
        self.glow_var = tk.DoubleVar(value=float(self.config["colors"]["glow_intensity"]))
        ttk.Scale(panel, from_=0.0, to=1.0, variable=self.glow_var,
                  command=lambda _value: self.redraw()).pack(fill="x", pady=8)

        ttk.Button(panel, text="Change primary", command=lambda: self._choose_color("primary")).pack(fill="x", pady=5)
        ttk.Button(panel, text="Change secondary", command=lambda: self._choose_color("secondary")).pack(fill="x", pady=5)
        ttk.Button(panel, text="Reload JSON", command=self._reload).pack(fill="x", pady=(18, 5))
        ttk.Button(panel, text="Save current config", command=self._save).pack(fill="x", pady=5)
        ttk.Button(panel, text="Reset preview", command=self._reset).pack(fill="x", pady=5)

        ttk.Label(panel, text="2D concept overlay only. Coordinates are design-canvas pixels, not measured motorcycle dimensions.",
                  wraplength=215, style="Sub.TLabel").pack(anchor="w", pady=(18, 0))

    def _sync_layers(self) -> None:
        self.visible = {key: var.get() for key, var in self.layer_vars.items()}
        self.redraw()

    def _choose_color(self, key: str) -> None:
        chosen = colorchooser.askcolor(self.config["colors"][key], title=f"Choose {key} neon")
        if chosen and chosen[1]:
            self.config["colors"][key] = chosen[1].upper()
            self.redraw()

    def _reload(self) -> None:
        try:
            self.config = load_config(self.config_path)
            self.glow_var.set(float(self.config["colors"]["glow_intensity"]))
            for key, var in self.layer_vars.items():
                var.set(True)
            self._sync_layers()
        except (OSError, ValueError, json.JSONDecodeError) as error:
            messagebox.showerror("Config error", str(error))

    def _save(self) -> None:
        self.config["colors"]["glow_intensity"] = round(self.glow_var.get(), 2)
        try:
            resolve_segments(self.config)
            self.config_path.write_text(json.dumps(self.config, indent=2) + "\n",
                                        encoding="utf-8")
            messagebox.showinfo("Saved", f"Skin configuration saved to {self.config_path.name}")
        except (OSError, ValueError) as error:
            messagebox.showerror("Save error", str(error))

    def _reset(self) -> None:
        self.config = copy.deepcopy(self._original)
        self.glow_var.set(float(self.config["colors"]["glow_intensity"]))
        for var in self.layer_vars.values():
            var.set(True)
        self._sync_layers()

    @staticmethod
    def _hex_rgb(color: str) -> tuple[int, int, int]:
        value = color.lstrip("#")
        return tuple(int(value[index:index + 2], 16) for index in (0, 2, 4))

    @staticmethod
    def _blend(color: str, factor: float) -> str:
        rgb = NeonSimulator._hex_rgb(color)
        values = [max(0, min(255, round(channel * factor))) for channel in rgb]
        return "#{:02x}{:02x}{:02x}".format(*values)

    def _draw_bike_guide(self) -> None:
        # Stylized side-view guide, deliberately not a ZX-25R dimensional drawing.
        self.canvas.create_oval(130, 365, 290, 525, outline="#354657", width=5)
        self.canvas.create_oval(490, 365, 650, 525, outline="#354657", width=5)
        self.canvas.create_oval(155, 390, 265, 500, outline="#253746", width=3)
        self.canvas.create_oval(515, 390, 625, 500, outline="#253746", width=3)
        self.canvas.create_line(210, 445, 360, 345, 550, 445,
                                fill="#41566a", width=8, smooth=True)
        self.canvas.create_polygon(255, 350, 330, 285, 460, 295, 535, 355,
                                   475, 380, 330, 375, fill="#1d2d3d",
                                   outline="#536a7e", width=3, smooth=True)
        self.canvas.create_polygon(430, 300, 530, 315, 590, 375, 510, 390,
                                   460, 360, fill="#1a2938",
                                   outline="#536a7e", width=3, smooth=True)
        self.canvas.create_line(505, 320, 565, 270, fill="#536a7e", width=7)
        self.canvas.create_line(565, 270, 625, 275, fill="#536a7e", width=5)
        self.canvas.create_text(24, 24, anchor="nw", text="SIDE PROFILE / DESIGN GUIDE",
                               fill="#8197aa", font=("Segoe UI", 10, "bold"))

    def redraw(self) -> None:
        self.canvas.delete("all")
        self._draw_bike_guide()
        intensity = max(0.0, min(1.0, float(self.glow_var.get())))
        for segment in resolve_segments(self.config):
            if not self.visible.get(segment["id"], True):
                continue
            points = [coordinate for point in segment["points"] for coordinate in point]
            color = segment["color"]
            width = segment["width"]
            # Layered strokes approximate glow in Tkinter; this is not a shader.
            halo = self._blend(color, 0.22 + intensity * 0.38)
            mid = self._blend(color, 0.48 + intensity * 0.42)
            self.canvas.create_line(*points, fill=halo,
                                    width=width * (3.0 + intensity * 3.0),
                                    smooth=True, capstyle=tk.ROUND, joinstyle=tk.ROUND)
            self.canvas.create_line(*points, fill=mid,
                                    width=width * (1.8 + intensity),
                                    smooth=True, capstyle=tk.ROUND, joinstyle=tk.ROUND)
            self.canvas.create_line(*points, fill=color, width=max(1, width * 0.65),
                                    smooth=True, capstyle=tk.ROUND, joinstyle=tk.ROUND)
            self.canvas.create_text(points[0], text=segment["id"].replace("_", " "),
                                    fill="#d9f7f1", anchor="sw",
                                    font=("Segoe UI", 8))


def main() -> None:
    root = tk.Tk()
    NeonSimulator(root)
    root.mainloop()


if __name__ == "__main__":
    main()
