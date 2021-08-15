shader_type spatial;

void fragment(){
	//ALBEDO = texture(DEPTH_TEXTURE, SCREEN_UV).rgb;
	ALBEDO.r = (FRAGCOORD.z - 0.1) / (1.0 - 0.1);  
}