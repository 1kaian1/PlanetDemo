shader_type spatial;

uniform sampler2D texture_albedo;

void fragment() {
    vec4 color = texture(texture_albedo, UV);

    // Pokud je pixel černý, změní se na bílý
    if (color.rgb == vec3(0.0)) {
        color.rgb = vec3(1.0); // Bílá
    }

    ALBEDO = color.rgb;
    ALPHA = color.a; // Zachovává průhlednost
}
