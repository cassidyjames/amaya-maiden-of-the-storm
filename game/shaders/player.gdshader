shader_type canvas_item;

uniform float shine_a = 0.0;
uniform float shine_b = 0.0;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float v = (c.r + c.b + c.g) / 3.0;
	vec4 c_a = vec4(v, v, v, c.a) * vec4(1.0, 2.0, 4.0, 1.0);
	vec4 c_b = vec4(v, v, v, c.a) * vec4(4.0, 4.0, 4.0, 1.0);
	COLOR = c;
	COLOR += c_a * shine_a;
	COLOR += c_b * shine_b;
}
