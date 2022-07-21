shader_type canvas_item;
uniform vec2 scroll = vec2(1,1);
uniform vec2 screen_size;
uniform float tile_count = 3;
uniform sampler2D texture_src;
uniform sampler2D mask_src;
uniform float mask_intensity;
uniform float tile_darkness;
uniform float cutoff : hint_range(-1,1);
uniform float slices_start_offset : hint_range(0,1);
uniform float cutoff_bottom_diff_multiplier : hint_range(0,1);
uniform int slices : hint_range(0,100);
uniform vec4 slice_start_color : hint_color;
uniform float slice_distance_multiplier = 0;

void fragment(){
	ivec2 texture_size = textureSize(texture_src, 0);
	vec4 mask = texture(mask_src, UV);
	
	vec2 tile_uv;
	
	tile_uv.x = UV.x*((screen_size.x/float(texture_size.x) * tile_count)) - TIME * scroll.x;
	tile_uv.y = UV.y*((screen_size.y/float(texture_size.y) * tile_count)) - TIME * scroll.y;
	
	// Load tiling texture
	vec4 texture = texture(texture_src, tile_uv);
	// Add individual darkness
	texture -= tile_darkness;
	
	COLOR.rgb = texture.rgb - mask.rgb * mask_intensity;
	
	float cutoff_bottom_difference = (1.0 - cutoff) * cutoff_bottom_diff_multiplier;
	
	// render cutoff slices
	float slice_distance = 1.0 - cutoff;
	
	
	
	if(cutoff < 1.0){ // Don't render colour slices if cutoff is greater than one
		for(int slice = 0; slice <= slices; slice++){
			if(UV.x < cutoff + slices_start_offset - cutoff_bottom_difference * UV.y - float(slice) * slice_distance * float(slice) * slice_distance * slice_distance_multiplier){
				if(slice==0 && slices == 0 || slice==slices){
					COLOR.rgb = vec3(0,0,0);
				} else {
					COLOR.rgb = slice_start_color.rgb - (vec3(0.1,0.1,0.1) * float(slice));
				}
			}
		}
	} else {
		COLOR.rbg = vec3(0,0,0);
	}
}