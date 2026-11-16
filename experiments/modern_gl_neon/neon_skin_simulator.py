# ==============================================================================
#  Atomic-Z-Customi-Z v1.0 (Production Release)
#  Real-Time 3D Neon Skin Simulator for Kawasaki Ninja ZX-25R
#  Engine: Python 3.10+ | moderngl-window | ModernGL | GLFW
# ==============================================================================

import moderngl_window as mglw
import moderngl
import numpy as np
import time
import os
import sys
import logging

# ------------------------------------------------------------------------------
# 1. LOGGING & CONFIGURATION
# ------------------------------------------------------------------------------
logging.basicConfig(level=logging.INFO, format='[%(levelname)s] %(message)s')
logger = logging.getLogger(__name__)

CONFIG = {
    "bike": {
        "model": "Kawasaki Ninja ZX-25R SE",
        "dimensions_mm": {"length": 1980, "width": 750, "height": 1110, "wheelbase": 1380},
        "curb_mass_kg": 184,
        "engine": {"displacement_cc": 250, "cylinders": 4, "max_power_hp": 46},
        "model_path": "assets/models/zx25r.obj"  # مسیر مدل سه‌بعدی
    },
    "neon": {
        "primary_color": (0.0, 1.0, 0.8, 1.0),   # Cyan
        "secondary_color": (1.0, 0.0, 1.0, 1.0), # Magenta
        "glow_strength": 3.5,
        "glow_falloff": 8.0,
        "pulse_speed": 3.0
    },
    "renderer": {
        "window_size": (1280, 720),
        "vsync": True,
        "clear_color": (0.02, 0.02, 0.05, 1.0)
    }
}

# ------------------------------------------------------------------------------
# 2. SHADERS (GLSL) - Advanced Neon Rendering
# ------------------------------------------------------------------------------
VERTEX_SHADER = """
#version 330 core
uniform mat4 mvp;
in vec3 in_position;
in vec3 in_normal;
out vec3 v_normal;
out vec2 v_uv;

void main() {
    v_normal = in_normal;
    v_uv = in_position.xy;
    gl_Position = mvp * vec4(in_position, 1.0);
}
"""

FRAGMENT_SHADER = """
#version 330 core
in vec3 v_normal;
in vec2 v_uv;
out vec4 f_color;

uniform vec3 u_primary;
uniform vec3 u_secondary;
uniform float u_time;
uniform float u_glow_strength;
uniform float u_glow_falloff;
uniform float u_pulse_speed;

void main() {
    // 1. محاسبه فاصله از مرکز خط نئون
    float dist = abs(v_uv.y - 0.5);
    float glow = pow(1.0 - dist * 2.0, u_glow_falloff);
    glow = clamp(glow, 0.0, 1.0) * u_glow_strength;

    // 2. پالس نوری سینمایی
    float pulse = 0.9 + 0.1 * sin(u_time * u_pulse_speed);
    
    // 3. ترکیب رنگ اصلی و ثانویه بر اساس نرمال (برای تنوع بصری)
    float mix_factor = smoothstep(0.0, 1.0, abs(v_normal.y));
    vec3 neon_color = mix(u_primary, u_secondary, mix_factor);
    
    // 4. نور محیطی ملایم
    vec3 ambient = neon_color * 0.15;
    vec3 final_color = (neon_color * glow * pulse) + ambient;
    
    f_color = vec4(final_color, 1.0);
}
"""

# ------------------------------------------------------------------------------
# 3. RENDERER CLASS
# ------------------------------------------------------------------------------
class NeonSkinSimulator(mglw.WindowConfig):
    gl_version = (3, 3)
    title = "Atomic-Z Customi-Z | ZX-25R Neon Skin"
    window_size = CONFIG["renderer"]["window_size"]
    vsync = CONFIG["renderer"]["vsync"]
    clear_color = CONFIG["renderer"]["clear_color"]

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        logger.info(f"Initializing {CONFIG['bike']['model']} Simulator...")
        
        # 1. بارگذاری مدل سه‌بعدی (در صورت وجود)
        self.scene = None
        model_path = CONFIG["bike"]["model_path"]
        if os.path.exists(model_path):
            try:
                self.scene = self.load_scene(model_path)
                logger.info(f"Loaded model: {model_path}")
            except Exception as e:
                logger.warning(f"Failed to load model: {e}. Using procedural geometry.")
        else:
            logger.warning(f"Model not found at {model_path}. Using procedural geometry.")
            self._create_fallback_geometry()

        # 2. ایجاد برنامه شیدر
        self.program = self.ctx.program(
            vertex_shader=VERTEX_SHADER,
            fragment_shader=FRAGMENT_SHADER
        )
        self._set_uniforms()

        # 3. تنظیمات دوربین
        self.camera_position = (0.0, 1.0, 4.0)
        self.camera_target = (0.0, 0.5, 0.0)
        self.camera_speed = 0.05
        self.model_matrix = np.eye(4, dtype='f4')

        # 4. پروفایلر عملکرد
        self.frame_count = 0
        self.start_time = time.time()
        self.fps = 0.0

    def _create_fallback_geometry(self):
        """هندسه جایگزین در صورت عدم وجود مدل سه‌بعدی"""
        # خطوط نئونی ساده به عنوان جایگزین
        vertices = np.array([
            -0.8, 0.4, 0.0,  0.0, 1.0, 0.0,
             0.8, 0.5, 0.0,  0.0, 1.0, 0.0,
            -0.6, 0.0, 0.0,  0.0, 1.0, 0.0,
             0.2, 0.1, 0.0,  0.0, 1.0, 0.0,
             0.2, 0.7, 0.0,  1.0, 0.0, 1.0,
             0.8, 0.3, 0.0,  1.0, 0.0, 1.0,
        ], dtype='f4')
        
        self.vbo = self.ctx.buffer(vertices.tobytes())
        self.vao = self.ctx.vertex_array(
            self.program, [(self.vbo, '3f 3f', 'in_position', 'in_normal')]
        )
        self.scene = None
        logger.info("Fallback geometry initialized.")

    def _set_uniforms(self):
        """تنظیم مقادیر اولیه یونیفرم‌ها"""
        self.program['u_primary'].value = CONFIG["neon"]["primary_color"][:3]
        self.program['u_secondary'].value = CONFIG["neon"]["secondary_color"][:3]
        self.program['u_glow_strength'].value = CONFIG["neon"]["glow_strength"]
        self.program['u_glow_falloff'].value = CONFIG["neon"]["glow_falloff"]
        self.program['u_pulse_speed'].value = CONFIG["neon"]["pulse_speed"]

    def on_render(self, time, frametime):
        # 1. به‌روزرسانی یونیفرم زمان برای پالس
        self.program['u_time'].value = time
        
        # 2. محاسبه ماتریس MVP (ساده شده)
        # در نسخه‌های بعدی می‌توان از pyrr برای محاسبه دقیق View و Projection استفاده کرد
        mvp = self._compute_mvp()
        self.program['mvp'].write(mvp)

        # 3. رندر
        if self.scene:
            self.scene.draw(self.program)
        else:
            self.vao.render(moderngl.LINES)

        # 4. پروفایلر
        self._update_fps()

    def _compute_mvp(self):
        """محاسبه ماتریس Model-View-Projection"""
        # برای سادگی، از یک ماتریس پروجکشن پرسپکتیو ساده استفاده می‌کنیم
        # در عمل باید از pyrr یا numpy برای محاسبات دقیق‌تر استفاده کرد
        fov = 60.0
        aspect = self.window_size[0] / self.window_size[1]
        near, far = 0.1, 100.0
        f = 1.0 / np.tan(np.radians(fov) / 2.0)
        
        proj = np.array([
            [f / aspect, 0, 0, 0],
            [0, f, 0, 0],
            [0, 0, (far + near) / (near - far), (2 * far * near) / (near - far)],
            [0, 0, -1, 0]
        ], dtype='f4')
        
        # ماتریس View (دوربین ساده)
        eye = np.array(self.camera_position)
        target = np.array(self.camera_target)
        up = np.array([0.0, 1.0, 0.0])
        
        f_dir = (target - eye) / np.linalg.norm(target - eye)
        s = np.cross(f_dir, up)
        s /= np.linalg.norm(s)
        u = np.cross(s, f_dir)
        
        view = np.eye(4, dtype='f4')
        view[0, :3] = s
        view[1, :3] = u
        view[2, :3] = -f_dir
        view[0, 3] = -np.dot(s, eye)
        view[1, 3] = -np.dot(u, eye)
        view[2, 3] = np.dot(f_dir, eye)
        
        return proj @ view @ self.model_matrix

    def _update_fps(self):
        self.frame_count += 1
        elapsed = time.time() - self.start_time
        if elapsed >= 1.0:
            self.fps = self.frame_count / elapsed
            self.frame_count = 0
            self.start_time = time.time()
            logger.info(f"FPS: {self.fps:.2f} | Frame: {(1.0/self.fps)*1000:.2f} ms")

    def on_key_event(self, key, action, modifiers):
        if key == self.wnd.keys.ESCAPE and action == self.wnd.keys.ACTION_PRESS:
            self.wnd.close()

# ------------------------------------------------------------------------------
# 4. MAIN ENTRY POINT
# ------------------------------------------------------------------------------
if __name__ == '__main__':
    logger.info("=" * 60)
    logger.info(f"  {CONFIG['bike']['model']} Neon Skin Simulator")
    logger.info(f"  Engine: {CONFIG['bike']['engine']['cylinders']}-Cylinder, {CONFIG['bike']['engine']['displacement_cc']}cc")
    logger.info(f"  Max Power: {CONFIG['bike']['engine']['max_power_hp']} HP")
    logger.info("=" * 60)
    
    try:
        NeonSkinSimulator.run()
    except Exception as e:
        logger.error(f"Fatal error: {e}", exc_info=True)
        sys.exit(1)
