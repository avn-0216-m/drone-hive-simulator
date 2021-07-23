shader_type canvas_item;  
uniform sampler2D background;
uniform float scroll_speed;  
void fragment(){
	//COLOR = vec4(0,0,0,1)
    COLOR = vec4(texture(background, vec2(UV.y*5.0+TIME/scroll_speed, UV.x*5.0+TIME/scroll_speed)).rgb, 1);
}