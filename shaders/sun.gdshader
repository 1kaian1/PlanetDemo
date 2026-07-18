shader_type spatial;
render_mode unshaded, blend_add;

uniform vec3 glow_color = vec3(1.0, 1.0, 1.0);
uniform float glow_strength = 50.0;
uniform float fade_radius = 200.0;

void fragment() {
    float dist = length(VERTEX); // vzdálenost od středu koule
    float alpha = clamp(1.0 - dist / fade_radius, 0.0, 1.0); // fade na okraji

    ALBEDO = glow_color;
    EMISSION = glow_color * glow_strength * alpha; // slabší záře na okraji
}
