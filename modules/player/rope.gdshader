shader_type canvas_item;

render_mode blend_mix;

uniform vec2 point_a = vec2(0.0); 
uniform vec2 point_b = vec2(0.0);
uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float thickness = 2.0;

uniform float amplitude = 20.0;
uniform float frequency = 0.05;
uniform float speed = 2.0;

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec2 p = world_pos;
	
	vec2 ba = point_b - point_a;
	vec2 pa = p - point_a;
	
	float ba_dot_ba = dot(ba, ba);
	if (ba_dot_ba == 0.0) {
		discard;
	}
	
	float h = clamp(dot(pa, ba) / ba_dot_ba, 0.0, 1.0);
	float taper = sin(PI * h);
	
	vec2 normal = vec2(-ba.y, ba.x);
	float len_ba = length(ba);
	normal /= len_ba;
	
	float wave = sin(h * len_ba * frequency + TIME * speed) * amplitude * taper;
	vec2 closest_point = point_a + ba * h + normal * wave;
	
	float dist = length(p - closest_point);
	
	float alpha = smoothstep(thickness, thickness - 1.0, dist);
	COLOR = vec4(line_color.rgb, line_color.a * alpha);
}
