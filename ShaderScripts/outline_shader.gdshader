shader_type spatial;
render_mode blend_mix, cull_front, unshaded;

uniform vec4 color : source_color = vec4(1,0,0,1);
uniform float size = 1.05;
uniform float y_offset = 0.5;

void vertex() {
    vec3 center = vec3(0.0, y_offset, 0.0);
    VERTEX = (VERTEX - center) * size + center;
}

void fragment() {
    ALBEDO = color.rgb;
    ALPHA = color.a;
}