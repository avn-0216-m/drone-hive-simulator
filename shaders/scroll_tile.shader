shader_type canvas_item;
uniform vec2 scroll = vec2(1,1);
uniform vec2 screen_size;
uniform float tile_size = 3;

void fragment(){
	ivec2 texture_size = textureSize(TEXTURE, 0);
	COLOR = texture(TEXTURE, UV*tile_size-TIME * scroll);
}