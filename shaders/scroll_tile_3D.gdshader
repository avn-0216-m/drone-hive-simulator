shader_type spatial;
render_mode specular_disabled;
uniform sampler2D tile_source : hint_albedo;
uniform float tile_density;
uniform float alternate_line_offset;
uniform vec2 scroll;
uniform float height_correction;

uniform bool flip_x = false;
uniform bool flip_y = false;

void fragment() {
	
	ivec2 tile_pixel_size = textureSize(tile_source, 0);
	float ratio = (float(tile_pixel_size.y) / float(tile_pixel_size.x));
	
	vec2 tile_uv = vec2(
		UV.x * tile_density * ratio + TIME * scroll.x,
		UV.y * tile_density * height_correction	 + TIME * scroll.y
	);
	
	tile_uv.x *= ((float(flip_x) - 0.5) * 2.0);
	tile_uv.y *= ((float(flip_y) - 0.5) * 2.0);
	
	if(mod(floor(tile_uv.y), 2.0) == 0.0){
		tile_uv.x += alternate_line_offset;
	}
	
	tile_uv.x += alternate_line_offset * mod(round(tile_uv.y + 0.5), 2.0);
	
	ALBEDO = texture(tile_source, tile_uv).rgb;
}
