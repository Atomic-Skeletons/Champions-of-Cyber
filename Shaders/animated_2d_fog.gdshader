shader_type canvas_item;

// Assign these in the Inspector. All must be seamless/tileable.
uniform sampler2D noise_tex : repeat_enable, filter_linear;
uniform sampler2D warp_tex : repeat_enable, filter_linear;
uniform sampler2D detail_tex : repeat_enable, filter_linear;
uniform float detail_weight : hint_range(0.0, 1.0) = 0.25;

// Fade mask: a GradientTexture2D (NOT repeating, it spans the whole area once)
uniform sampler2D fade_tex : repeat_disable, filter_linear;
uniform float fade_amount : hint_range(0.0, 1.0) = 1.0;  // 0 = no fade, 1 = full effect
uniform bool fade_invert = false;
uniform bool fade_screen_space = false;  // true: fade stays fixed to the camera view

uniform ivec2 noise_repeat = ivec2(1, 1);
uniform ivec2 warp_repeat = ivec2(1, 1);
uniform ivec2 detail_repeat = ivec2(3, 3);

uniform vec2 pixel_res = vec2(160.0, 96.0);
uniform float warp_strength : hint_range(0.0, 0.3) = 0.06;

uniform vec2 noise_speed = vec2(4.0, 0.0);
uniform vec2 warp_speed = vec2(-2.0, 3.0);
uniform vec2 detail_speed = vec2(-6.0, 1.0);

uniform float coverage : hint_range(0.0, 1.0) = 0.42;
uniform float softness : hint_range(0.01, 1.0) = 0.35;
uniform float density : hint_range(0.0, 1.0) = 0.7;
uniform int levels : hint_range(2, 16) = 6;
uniform float dither : hint_range(0.0, 1.0) = 0.5;

float bayer4(vec2 p) {
	ivec2 q = ivec2(mod(p, 4.0));
	const float m[16] = float[16](
		0.0, 8.0, 2.0, 10.0,
		12.0, 4.0, 14.0, 6.0,
		3.0, 11.0, 1.0, 9.0,
		15.0, 7.0, 13.0, 5.0);
	return (m[q.x + q.y * 4] + 0.5) / 16.0;
}

void fragment() {
	vec2 p = floor(UV * pixel_res);
	vec2 cell_uv = (p + 0.5) / pixel_res;

	vec2 off_noise  = fract(TIME * noise_speed  / pixel_res);
	vec2 off_warp   = fract(TIME * warp_speed   / pixel_res);
	vec2 off_detail = fract(TIME * detail_speed / pixel_res);

	vec2 w_uv = (cell_uv + off_warp) * vec2(warp_repeat);
	float wx = texture(warp_tex, w_uv).r;
	float wy = texture(warp_tex, w_uv + vec2(0.37, 0.61)).r;
	vec2 warp = (vec2(wx, wy) - 0.5) * 2.0 * warp_strength;

	vec3 main_col = texture(noise_tex, (cell_uv + off_noise) * vec2(noise_repeat) + warp).rgb;
	vec3 det_col = texture(detail_tex, (cell_uv + off_detail) * vec2(detail_repeat) + warp * 1.5).rgb;
	vec3 col = mix(main_col, det_col, detail_weight);

	float n = dot(col, vec3(0.299, 0.587, 0.114));
	float v = clamp((n - coverage) / softness, 0.0, 1.0);

	// --- Gradient fade ---
	// Sampled once per art pixel so the fade is pixelated too
	vec2 fade_uv = cell_uv;
	if (fade_screen_space) {
		fade_uv = (floor(SCREEN_UV * pixel_res) + 0.5) / pixel_res;
	}
	vec4 g = texture(fade_tex, fade_uv);
	float mask = dot(g.rgb, vec3(0.299, 0.587, 0.114)) * g.a;  // works with color ramps or alpha ramps
	if (fade_invert) mask = 1.0 - mask;
	v *= mix(1.0, mask, fade_amount);

	float steps = float(levels);
	float q = clamp(floor(v * steps + bayer4(p) * dither) / steps, 0.0, 1.0);

	COLOR = vec4(col, q * density);
}