shader_type spatial;
uniform sampler2D tile_source : hint_albedo;
uniform float tile_density;
uniform float alternate_line_offset;
uniform vec2 scroll;
uniform float height_correction;

void fragment() {
	
	ivec2 tile_pixel_size = textureSize(tile_source, 1);
	float ratio = (float(tile_pixel_size.y) / float(tile_pixel_size.x));
	
	vec2 tile_uv = vec2(
		UV.x * tile_density * ratio + TIME * scroll.x,
		UV.y * tile_density * height_correction + TIME * scroll.y
	);
	
	tile_uv.x += alternate_line_offset * mod(round(tile_uv.y + 0.5), 2.0);
	
	ALBEDO = texture(tile_source, tile_uv).rgb;
}
