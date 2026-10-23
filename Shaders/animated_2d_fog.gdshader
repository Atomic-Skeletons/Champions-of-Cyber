shader_type canvas_item;

// Assign this in the Inspector. Must be a seamless/tileable texture.
uniform sampler2D noise_tex : repeat_enable, filter_linear;
// Optional second layer for finer detail (can reuse the same texture)
uniform sampler2D detail_tex : repeat_enable, filter_linear;
uniform float detail_weight : hint_range(0.0, 1.0) = 0.35;

// How many times each texture repeats across one tile. Keep these INTEGERS or the tile will have a seam.
uniform ivec2 noise_repeat = ivec2(1, 1);
uniform ivec2 detail_repeat = ivec2(3, 3);

// Size of one tile in ART pixels. Keep both values multiples of 4 so the dither tiles too.
uniform vec2 pixel_res = vec2(160.0, 96.0);

uniform float coverage : hint_range(0.0, 1.0) = 0.42;
uniform float softness : hint_range(0.01, 1.0) = 0.35;

uniform vec4 color_shadow : source_color = vec4(0.45, 0.5, 0.65, 1.0);
uniform vec4 color_light : source_color = vec4(0.85, 0.9, 1.0, 1.0);
uniform float density : hint_range(0.0, 1.0) = 0.7;
uniform int levels : hint_range(2, 8) = 4;
uniform float dither : hint_range(0.0, 1.0) = 0.8;

// Drift in art pixels per second (whole pixels only, so nothing shimmers)
uniform vec2 scroll_speed = vec2(3.0, 0.0);

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
	// Snap to the art-pixel grid
	vec2 p = floor(UV * pixel_res);

	// Scroll in whole pixels, wrapped to the tile size
	p += mod(floor(TIME * scroll_speed), pixel_res);

	// Sample at the center of each art pixel so every pixel gets one flat value
	vec2 uv = (p + 0.5) / pixel_res;

	float n = texture(noise_tex, uv * vec2(noise_repeat)).r;
	float d = texture(detail_tex, uv * vec2(detail_repeat)).r;
	n = mix(n, d, detail_weight);

	float v = clamp((n - coverage) / softness, 0.0, 1.0);

	float steps = float(levels);
	float q = clamp(floor(v * steps + bayer4(p) * dither) / steps, 0.0, 1.0);

	vec3 col = mix(color_shadow.rgb, color_light.rgb, q);
	COLOR = vec4(col, q * density);
}