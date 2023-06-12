shader_type canvas_item;

uniform sampler2D growth_map: filter_nearest;
uniform float growth = 1.0;
uniform bool outline = false;

void fragment() {
	float growth_req = texture(growth_map, UV).r;
	if (growth > growth_req) {
		COLOR.rgba = texture(TEXTURE, UV);
		if (outline && COLOR.a > 0.0) {
			COLOR.rgba = vec4(0.0, 0.0, 0.0, 1.0);
		}
	}
	else {
		COLOR.rgba = vec4(1.0, 1.0, 1.0, 0.0);
	}
}
