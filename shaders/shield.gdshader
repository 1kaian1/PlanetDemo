shader_type spatial;
render_mode cull_disabled;

uniform float cut_local = 0.46; // 0..1
uniform vec3 cut_axis = vec3(0,1,0); // lokální osa pro řez
uniform mat3 rotation_matrix = mat3(1.0); // nastavíš skriptem

varying float local_height;

void vertex() {
    // otočíme vertex podle zadané rotace
    vec3 rotated = rotation_matrix * VERTEX;
    local_height = dot(rotated, cut_axis);
}

void fragment() {
    if (local_height < cut_local) discard;

	EMISSION = vec3(0.5, 0.5, 0.5);

}
