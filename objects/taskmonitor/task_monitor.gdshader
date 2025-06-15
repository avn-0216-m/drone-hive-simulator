shader_type canvas_item;
render_mode unshaded;

uniform sampler2D sprite_texture: source_color, filter_nearest;

void fragment() {
	vec4 color = texture(sprite_texture, UV);
	COLOR.rgba = color;
}
