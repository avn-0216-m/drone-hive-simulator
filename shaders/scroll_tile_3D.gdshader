shader_type spatial;
render_mode cull_back,unshaded;
uniform sampler2D tile_source : hint_albedo;
uniform float tile_density;
uniform float alternate_line_offset;
uniform vec2 scroll;

void fragment() {
	
	ivec2 tile_pixel_size = textureSize(tile_source, 1);
	float ratio = (float(tile_pixel_size.y) / float(tile_pixel_size.x));
	
	vec2 tile_uv;
	
	tile_uv.x = (UV.x * tile_density * ratio) + TIME * scroll.x;
	tile_uv.y = (UV.y * tile_density) + TIME * scroll.y;
	
	tile_uv.x += alternate_line_offset * mod(round(tile_uv.y + 0.5), 2.0);
	
	ALBEDO = texture(tile_source, tile_uv).rgb * vec3(0.5,0.5,0.5);
}
