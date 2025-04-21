shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    tex_color.rgb = vec3(1.0, 1.0, 1.0);  // Červená barva
    tex_color.a *= 1.0;  // ✅ Nastavení poloprůhlednosti (50 %)
    COLOR = tex_color;
}


//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
