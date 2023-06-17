shader_type canvas_item;

uniform sampler2D flame: repeat_enable, filter_nearest;
uniform float multiplier = 1.0;

void fragment() {
	vec2 fire_uv = (UV * vec2(1.0, 0.25)) + vec2(0.0, (SCREEN_UV.x) + TIME / 2.0);
	fire_uv.x = floor(fire_uv.x * 32.0) / 32.0;
	fire_uv.y = floor(fire_uv.y * 128.0) / 128.0;
	vec2 uv = UV;
	uv.x = floor(uv.x * 32.0) / 32.0;
	uv.y = floor(uv.y * 32.0) / 32.0;
	
	float fire = texture(flame, fire_uv).r;
	fire *= texture(TEXTURE, uv).r;
	fire *= multiplier;
	if (fire >= 0.30) {
		COLOR.rgb = vec3(1.0, 1.0, 1.0);
	}
	else if (fire >= 0.15) {
		COLOR.rgb = vec3(1.0, 1.0, 0.5);
	}
	else if (fire >= 0.1) {
		COLOR.rgb = vec3(1.0, 0.75, 0.0);
	}
	else {
		COLOR.rgba = vec4(1.0, 1.0, 1.0, 0.0);
	}
}
