shader_type spatial;

uniform vec3 aura_color = vec3(1.0, 1.0, 1.0);
uniform float radius = 2.0;

void fragment() {
    // pozice fragmentu relativně ke středu objektu
    vec3 local_pos = VERTEX;
    float dist = length(local_pos);

    // fade od středu
    float alpha = clamp(1.0 - (dist / radius), 0.0, 1.0);

    ALBEDO = aura_color;
    ALPHA = alpha;
}
