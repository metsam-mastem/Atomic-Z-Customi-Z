shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never;

uniform vec4 neon_color : source_color = vec4(0.0, 1.0, 0.8, 1.0);
uniform float glow_intensity : hint_range(0.0, 10.0, 0.05) = 3.0;
uniform float pulse_speed : hint_range(0.0, 10.0, 0.05) = 2.0;
uniform float core_width : hint_range(0.05, 1.0, 0.01) = 0.35;
uniform float falloff_power : hint_range(0.5, 8.0, 0.1) = 2.5;
uniform float opacity : hint_range(0.0, 1.0, 0.01) = 0.9;

void fragment() {
    float pulse = pulse_speed > 0.0
        ? 0.8 + 0.2 * sin(TIME * pulse_speed)
        : 1.0;

    // Fresnel edge response: brighter at grazing viewing angles.
    float facing = clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0);
    float rim = pow(1.0 - facing, falloff_power);

    // Core is retained at all angles; rim contributes a soft halo.
    float core = mix(0.65, 1.0, core_width);
    vec3 emission_color = neon_color.rgb * glow_intensity * pulse * (core + rim);

    ALBEDO = neon_color.rgb;
    EMISSION = emission_color;
    ALPHA = opacity * neon_color.a;
}
