shader_type spatial;  
uniform sampler2D background;
uniform float scroll_speed;  
void fragment(){
     ALBEDO = texture(background, vec2(UV.y*5.0+TIME/scroll_speed, UV.x*5.0+TIME/scroll_speed)).rgb;
}