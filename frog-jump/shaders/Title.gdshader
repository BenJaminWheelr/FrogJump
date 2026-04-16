shader_type canvas_item;

uniform float speed : hint_range(0.0, 10.0) = 3.0;
uniform float frequency : hint_range(0.0, 10.0) = 5.0;
uniform float amplitude : hint_range(0.0, 50.0) = 5.0;
uniform bool rainbow = true;

void vertex() {
	// Adds vertical "wave" motion
	VERTEX.y += sin(TIME * speed + VERTEX.x / frequency) * amplitude;
}

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	if (rainbow) {
		// Cycles through rainbow colors based on time and position
		float hue = TIME * speed * 0.1 + UV.x;
		vec3 rgb = mix(vec3(1.0), 0.5 + 0.5 * cos(6.28318 * (hue + vec3(0.0, 0.33, 0.67))), 1.0);
		COLOR = vec4(rgb, tex_color.a);
	} else {
		COLOR = tex_color;
	}
}
