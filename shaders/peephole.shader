shader_type spatial;
render_mode depth_draw_alpha_prepass;
uniform sampler2D wall_src;
uniform sampler2D noise;

uniform vec2 wall_uv;
uniform vec2 wall_offset;

uniform vec2 circle_center;
uniform float radius;

uniform float swirl_factor = 4;
uniform float swirl_speed = 0.5;

uniform float alias_factor = 6;

const mat4 thresholds = mat4(vec4(1, 9, 3, 11), vec4(13,5,15,7), vec4(4, 12, 2, 10), vec4(16,8,14,6));


void fragment(){
	vec4 wall_texture = texture(wall_src, vec2((wall_uv*UV) + wall_offset));
	vec4 noise_texture = texture(noise, UV);
	ALBEDO = wall_texture.rgb;
	
	// calculate distance from circle center to pixel using pythagoras
	float center_distance_to_x = pow(((floor(FRAGCOORD.x / alias_factor)) * alias_factor) - circle_center.x + sin(TIME * swirl_speed) * swirl_factor, 2.0);
	float center_distance_to_y = pow(((floor(FRAGCOORD.y / alias_factor)) * alias_factor) - circle_center.y + cos(TIME * swirl_speed) * swirl_factor, 2.0);
	
	//float center_distance_to_x = pow(FRAGCOORD.x - circle_center.x + sin(TIME * swirl_speed) * swirl_factor, 2.0);
	//float center_distance_to_y = pow(FRAGCOORD.y - circle_center.y + sin(TIME * swirl_speed) * swirl_factor, 2.0);
	
	if(center_distance_to_x + center_distance_to_y < pow(radius, 2)){
		//ALPHA = 1.0 - (radius - 0.0) / (max_radius - 0.0);
		ALPHA = 0.0;
	}
	
	
	
}