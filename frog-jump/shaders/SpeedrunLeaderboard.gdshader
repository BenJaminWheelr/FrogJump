shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.0, 0.5, 1.0, 1.0);
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.1;

void fragment() {
	// 1. Static Scanlines based on vertical UV
	float scanline = sin(UV.y * 250.0) * scanline_strength;
	
	// 2. Simple Vignette (darkens corners)
	float vignette = UV.x * UV.y * (1.0 - UV.x) * (1.0 - UV.y);
	vignette = clamp(pow(16.0 * vignette, 0.2), 0.0, 1.0);
	
	// 3. Combine with high multiplier for WorldEnvironment Glow
	vec3 final_color = (base_color.rgb - scanline) * vignette;
	
	COLOR = vec4(final_color * 2.5, base_color.a);
}