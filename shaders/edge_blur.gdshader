shader_type canvas_item;

// (x - 0.5) * 2
// f(1) = 1
// f(0) = -1

uniform float blur_quality = 1.0; // higher = more iterations
uniform float radius = 4.0;

void fragment(){
	float edge = round(UV.x);
	float distance_to_center = distance(vec2(0.5, UV.y), UV);
	vec4 blurred = texture(TEXTURE, UV);
	
	//float radius = distance_to_center * 10.0 * blur_amount;
	int iterations = int(distance_to_center * 10.0 * blur_quality);
	
	for(int i = iterations; i != 0; i--){
		blurred += texture(TEXTURE, UV + vec2(0.0, radius * float(i)) * TEXTURE_PIXEL_SIZE);
	}
	
	blurred /= float(iterations + 1);
	
//	blurred += texture(TEXTURE, UV + vec2(0.0, radius) * TEXTURE_PIXEL_SIZE);
//	blurred += texture(TEXTURE, UV + vec2(0.0, -radius) * TEXTURE_PIXEL_SIZE);
//	blurred += texture(TEXTURE, UV + vec2(radius, 0.0) * TEXTURE_PIXEL_SIZE);
//	blurred += texture(TEXTURE, UV + vec2(-radius, 0.0) * TEXTURE_PIXEL_SIZE);
//
//	blurred += texture(TEXTURE, UV + vec2(-radius, -radius) * TEXTURE_PIXEL_SIZE);
//	blurred += texture(TEXTURE, UV + vec2(radius, radius) * TEXTURE_PIXEL_SIZE);
//	blurred += texture(TEXTURE, UV + vec2(-radius, radius) * TEXTURE_PIXEL_SIZE);
//	blurred += texture(TEXTURE, UV + vec2(radius, -radius) * TEXTURE_PIXEL_SIZE);
//
//	blurred /= 9.0;

	COLOR = blurred;
}