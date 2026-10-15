shader_type canvas_item;

uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float flash_modifier : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    vec3 final_color = mix(color.rgb, flash_color.rgb, flash_modifier);
    COLOR = vec4(final_color, color.a);
}