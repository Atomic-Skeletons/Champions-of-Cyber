shader_type canvas_item;

// Set the absolute maximum number of outlines you want to support here.
// Increase this number if you need more than 64 stacked outlines!
const int MAX_OUTLINES = 64;

// Slider to control how many outlines are actually drawn
uniform int active_outlines : hint_range(0, 10) = 3;
uniform float line_thickness : hint_range(0, 10) = 1.0;

// Array of colors for your outlines. Make sure the size is higher than the active outlines!
uniform vec4 outline_colors[64] : source_color;

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
	
	// Grab the original sprite color and transparency
	vec4 original_color = texture(TEXTURE, UV);
	float alpha = original_color.a;
	
	// Start with a distance higher than any possible outline
	float min_dist = 9999.0;

	// GLSL loops require constant bounds, so we loop up to MAX_OUTLINES
	for (int i = -MAX_OUTLINES; i <= MAX_OUTLINES; i++) {
		for (int j = -MAX_OUTLINES; j <= MAX_OUTLINES; j++) {
			int manhattan = abs(i) + abs(j);
			
			if (manhattan > active_outlines || manhattan == 0) continue;
			
			vec2 offset = vec2(float(i), float(j)) * size;
			float sample_alpha = texture(TEXTURE, UV + offset).a;
			
			if (sample_alpha > 0.0) {
				min_dist = min(min_dist, float(manhattan));
			}
		}
	}

	vec4 final_color = original_color;

	// Apply outlines only to transparent pixels that are close enough to the sprite
	if (alpha == 0.0 && min_dist <= float(active_outlines)) {
		int color_index = int(min_dist) - 1;
		final_color = outline_colors[color_index]; 
	}

	COLOR = final_color;
}