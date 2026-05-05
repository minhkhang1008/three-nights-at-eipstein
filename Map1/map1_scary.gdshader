shader_type spatial;
render_mode cull_front, unshaded; 

uniform float outline_thickness : hint_range(0.0, 1.0) = 0.01; 
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 0.0, 1.0); 
uniform vec4 emission_color : source_color = vec4(1.0, 1.0, 0.0, 1.0); 
uniform float emission_energy = 5.0; 

void vertex() {
	VERTEX += NORMAL * outline_thickness;
}

void fragment() {
	ALBEDO = outline_color.rgb;
	ALPHA = outline_color.a;
	EMISSION = emission_color.rgb * emission_energy;
}