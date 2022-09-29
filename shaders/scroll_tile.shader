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
uniform float alternate_line_offset = 0.5;
uniform sampler2D fisheye_gradient;
uniform float fisheye_offset_x = 0.5;
uniform float fisheye_offset_y = 0.5;

uniform float fisheye_start : hint_range(0, 1);
uniform float fisheye_end : hint_range(0, 1);
uniform float fisheye_intensity;

uniform float sine_mag;
uniform float sine_offset_1;
uniform float sine_offset_2;
uniform float sine_offset_3;

uniform float neutral;

uniform float test2;

uniform vec2 tile_uvs;

float test(float input){
	return (exp((2.0 * input - 1.0)) + 1.0) * - 1.0;
}

void fragment(){
	
	vec4 fisheye_texture = texture(fisheye_gradient, UV);
	
	ivec2 texture_size = textureSize(texture_src, 0);
	vec4 mask = texture(mask_src, UV);
	
	vec2 tile_uv;
	
	float modulate = 2.0;
	float modulate2 = 1.0;
	
	tile_uv.x = (UV.x)*((screen_size.x/float(texture_size.x) * tile_count )) - TIME * scroll.x;
	tile_uv.y = (UV.y)*((screen_size.y/float(texture_size.y) * tile_count )) - TIME * scroll.y;
	
	//tile_uv.x = tile_uv.x * UV.y;
	
	COLOR.rgb = vec3(0,0,0);
//

//	if(UV.x < 0.5){
//		tile_uv.x += mix(UV.x, round(UV.x), UV.x);
//	} else {
//		tile_uv.x += mix(round(UV.x), UV.x, UV.x);
//	}

	
	// Vertical offset, hori offset, magnitude
//	if(UV.x < dist){
//		tile_uv.x -= dist * UV.x * 2.0;
//		//COLOR = vec4(0,0,0,0);
//	}
	
//	if(UV.y < fisheye_start + sine_offset_3 - sin((UV.x + sine_offset_1) * sine_offset_2) * sine_mag){
//		tile_uv.y -= fisheye_start + sine_offset_3 - sin((UV.x + sine_offset_1) * sine_offset_2) * sine_mag
//	}
//
//	if(UV.x > fisheye_end - sin((UV.y + 3.5) * 2.0) * 0.1){
//		tile_uv.x += 0.1;
//	}




	
	tile_uv.x += mod(floor(tile_uv.y), modulate) * alternate_line_offset;
	
	// Load tiling texture
	vec4 texture = texture(texture_src, tile_uv);
	// Add individual darkness
	texture -= tile_darkness;
	


//	COLOR.r = tile_uv.r;
//	COLOR.g = tile_uv.g;
//	COLOR.b = 0.0;
	
	COLOR.rgb = texture.rgb;

	
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
	
	//COLOR.rgb = fisheye_texture.rgb;
	
}