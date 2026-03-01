shader_type spatial;
render_mode specular_schlick_ggx;

uniform sampler2D albedo_texture : source_color;
uniform vec4 albedo_color : source_color = vec4(1.0);

uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float roughness : hint_range(0.0, 1.0) = 0.5;

uniform float scroll_speed : hint_range(-5.0, 5.0) = 1.0;

void fragment() {
    // Scroll UVs horizontally
    vec2 uv = UV;
    uv.x = fract(uv.x + TIME * scroll_speed);

    vec4 tex = texture(albedo_texture, uv);

    ALBEDO = tex.rgb * albedo_color.rgb;
    METALLIC = metallic;
    ROUGHNESS = roughness;
}