shader_type canvas_item;

uniform float speed : hint_range(0.0, 10.0) = 3.0;
uniform float frequency : hint_range(0.0, 50.0) = 5.0;
uniform float amplitude : hint_range(0.0, 50.0) = 5.0;
uniform bool rainbow = true;
uniform bool vertical_rainbow = true;

void vertex() {
	// Vertical "wave" motion
	VERTEX.y += sin(TIME * speed + VERTEX.x / frequency) * amplitude;
}

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	
	if (rainbow) {
		// Choose axis for the rainbow gradient
		float axis = vertical_rainbow ? UV.y : UV.x;
		float hue = TIME * speed * 0.1 + axis;
		
		// Standard RGB conversion from hue
		vec3 rgb = 0.5 + 0.5 * cos(6.28318 * (hue + vec3(0.0, 0.33, 0.67)));
		
		// Apply the rainbow while preserving the texture's original transparency/mask
		COLOR = vec4(rgb, tex_color.a);
	} else {
		COLOR = tex_color;
	}
}