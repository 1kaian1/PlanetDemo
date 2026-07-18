shader_type spatial;

uniform sampler2D albedo_tex : hint_albedo;

void fragment() {
    // načtení barvy z textury
    vec4 tex_color = texture(albedo_tex, UV);
    ALBEDO = tex_color.rgb;
}
