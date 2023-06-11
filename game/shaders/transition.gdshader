shader_type canvas_item;

uniform float amount;

void fragment() {
	float a = texture(TEXTURE, UV).r;
	if (a > amount) {
		COLOR.rgba = vec4(0.0, 0.0, 0.0, 1.0);
	}
	else {
		COLOR.rgba = vec4(1.0, 1.0, 1.0, 0.0);
	}
}
