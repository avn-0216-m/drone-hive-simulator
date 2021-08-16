shader_type spatial;
render_mode depth_draw_alpha_prepass;
uniform sampler2D wall_src;

uniform vec2 wall_uv;
uniform vec2 wall_offset;

uniform vec2 circle_center;
uniform float radius = 0.0;
uniform float max_radius = 400;

uniform float swirl_factor = 8;
uniform float swirl_speed = 8;

uniform float alias_factor = 6;

uniform sampler2D alt_camera;

void fragment(){
	vec4 wall_texture = texture(wall_src, vec2((wall_uv*UV) + wall_offset));
	ALBEDO = wall_texture.rgb;
	
	// calculate distance from circle center to pixel using pythagoras
	float center_distance_to_x = pow(((floor(FRAGCOORD.x / alias_factor)) * alias_factor) - circle_center.x + sin(TIME * swirl_speed) * swirl_factor, 2.0);
	float center_distance_to_y = pow(((floor(FRAGCOORD.y / alias_factor)) * alias_factor) - circle_center.y + cos(TIME * swirl_speed) * swirl_factor, 2.0);
	
	//float center_distance_to_x = pow(FRAGCOORD.x - circle_center.x + sin(TIME * swirl_speed) * swirl_factor, 2.0);
	//float center_distance_to_y = pow(FRAGCOORD.y - circle_center.y + sin(TIME * swirl_speed) * swirl_factor, 2.0);
	
	if(center_distance_to_x + center_distance_to_y < pow(radius, 2)){
			ALPHA = 0.0;
	}
}