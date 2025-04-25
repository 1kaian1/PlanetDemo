extends MeshInstance3D

var fade_speed := 1 # Rychlost fade in/out
var is_fading_out := false
var is_fading_in := false

func fade_out():
	is_fading_out = true
	is_fading_in = false # Zajistí, že fade in není aktivní současně

func fade_in():
	is_fading_in = true
	is_fading_out = false # Zajistí, že fade out není aktivní současně
	
func _process(delta):
	var mesh = self.mesh  # Získá přidružený mesh	
	var material = mesh.surface_get_material(0)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if material and material is StandardMaterial3D:
		if is_fading_out:
			# Upravíme albedo_color.a pro průhlednost
			material.albedo_color.a -= fade_speed * delta
			if material.albedo_color.a <= 0.0:
				material.albedo_color.a = 0.0
				is_fading_out = false
		elif is_fading_in:
			material.albedo_color.a += fade_speed * delta
			if material.albedo_color.a >= 1.0:
				material.albedo_color.a = 1.0
				is_fading_in = false
