shader_type canvas_item;
uniform vec2 scroll = vec2(1,1);
uniform float scroll_speed = 1;
uniform vec2 screen_size;
uniform float tile_count = 3;
uniform sampler2D texture_src;
uniform sampler2D mask_src;
uniform float mask_intensity;
uniform float tile_darkness;

void fragment(){
	ivec2 texture_size = textureSize(texture_src, 0);
	vec4 mask = texture(mask_src, UV);
	
	vec2 tile_uv;
	
	tile_uv.x = UV.x*((screen_size.x/float(texture_size.x) * tile_count)) - TIME * scroll.x;
	tile_uv.y = UV.y*((screen_size.y/float(texture_size.y) * tile_count)) - TIME * scroll.y;
	
	vec4 texture = texture(texture_src, tile_uv);
	texture -= tile_darkness;
	
	COLOR.rgb = texture.rgb - mask.rgb * mask_intensity;
}