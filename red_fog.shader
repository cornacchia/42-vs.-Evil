// Shout out to Gonkee: https://github.com/Gonkee/Gonkees-Shaders
shader_type canvas_item;

uniform vec3 color = vec3(0.41, 0, 0);

const int OCTAVES = 4;

float rand(vec2 coord) {
	//return fract(sin(dot(coord, vec2(56, 78)) * 1000.0) * 1000.0);
	return fract(sin(dot(coord.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float noise(vec2 coord) {
	vec2 i = floor(coord);
	vec2 f = fract(coord);

	// top left
	float a = rand(i);
	// top right
	float b = rand(i + vec2(1.0, 0.0));
	// bottom left
	float c = rand(i + vec2(0.0, 1.0));
	// bottom right
	float d = rand(i + vec2(1.0, 1.0));
	
	vec2 cubic = f * f * (3.0 - 2.0 * f);
	
	return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
}

// fractal brownian motion
float fbm(vec2 coord) {
	float value = 0.0;
	float scale = 0.5;
	
	for (int i = 0; i < OCTAVES; i++) {
		value += noise(coord) * scale;
		coord *= 2.0;
		scale *= 0.5;
	}
	
	return value;
}

void fragment() {
	vec2 coord = UV * 20.0;
	
	vec2 motion = vec2(fbm(coord + vec2(TIME * -0.5, TIME * 0.5)));
	
	float final = fbm(coord + motion);
	
	COLOR = vec4(color, final * 0.5);
}