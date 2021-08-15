shader_type spatial;
render_mode depth_draw_alpha_prepass;
uniform sampler2D wall_src;

uniform vec2 wall_uv;
uniform vec2 wall_offset;

uniform vec2 circle_center;
uniform float radius = 0.0;
uniform float max_radius = 400;

uniform float swirl_factor = 4;
uniform float swirl_speed = 0.0;

uniform float alias_factor = 4;

uniform sampler2D alt_camera;



const mat4 thresholds = mat4(vec4(1, 9, 3, 11), vec4(13,5,15,7), vec4(4, 12, 2, 10), vec4(16,8,14,6));

float get_threshold(vec4 coord){
	
	// LMAO GODOT FORCES YOU TO USE CONST INTS TO ACCESS MATRIXES
	// ANYWAYS HERES 4 NESTED SWITCH STATEMENTS INSTEAD
	// values and concept from: https://ocias.com/blog/unity-stipple-transparency-shader/
	// thanks sebastian lauge
	
	float aliased_x = floor(coord.x / alias_factor) * alias_factor;
	float aliased_y = floor(coord.y / alias_factor) * alias_factor;
	
	switch(int(mod(aliased_x, 4))){
		case 0:
			switch(int(mod(aliased_y, 4))){
				case 0:
					return 1.0 / 17.0;
				case 1:
					return 9.0 / 17.0;
				case 2:
					return 3.0 / 17.0;
				case 3:
					return 11.0 / 17.0;
			}
		case 1:
			switch(int(mod(aliased_x, 4))){
				case 0:
					return 13.0 / 17.0;
				case 1:
					return 5.0 / 17.0;
				case 2:
					return 15.0 / 17.0;
				case 3:
					return 7.0 / 17.0;
			}
		case 2:
			switch(int(mod(aliased_x, 4))){
				case 0:
					return 4.0 / 17.0;
				case 1:
					return 12.0 / 17.0;
				case 2:
					return 2.0 / 17.0;
				case 3:
					return 10.0 / 17.0;
			}
		case 3:
			switch(int(mod(aliased_x, 4))){
				case 0:
					return 16.0 / 17.0;
				case 1:
					return 8.0 / 17.0;
				case 2:
					return 14.0 / 17.0;
				case 3:
					return 6.0 / 17.0;
			}
	}
	return 1.0;
}

void fragment(){
	vec4 wall_texture = texture(wall_src, vec2((wall_uv*UV) + wall_offset));
	ALBEDO = wall_texture.rgb;
	
	// calculate distance from circle center to pixel using pythagoras
	float center_distance_to_x = pow(((floor(FRAGCOORD.x / alias_factor)) * alias_factor) - circle_center.x + sin(TIME * swirl_speed) * swirl_factor, 2.0);
	float center_distance_to_y = pow(((floor(FRAGCOORD.y / alias_factor)) * alias_factor) - circle_center.y + cos(TIME * swirl_speed) * swirl_factor, 2.0);
	
	//float center_distance_to_x = pow(FRAGCOORD.x - circle_center.x + sin(TIME * swirl_speed) * swirl_factor, 2.0);
	//float center_distance_to_y = pow(FRAGCOORD.y - circle_center.y + sin(TIME * swirl_speed) * swirl_factor, 2.0);
	
	//if(center_distance_to_x + center_distance_to_y < pow(radius, 2)){
			// ALPHA = 0.0;
			// float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
			
			
	//}
}