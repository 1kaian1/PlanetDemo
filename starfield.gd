extends Node3D

const STAR_COUNT = 500
const STAR_FIELD_RADIUS = 300

func _ready():
	
	var star_mesh = SphereMesh.new()

	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = star_mesh
	mm.instance_count = STAR_COUNT

	var star_mmi = MultiMeshInstance3D.new()
	star_mmi.multimesh = mm
	add_child(star_mmi)

	# Shader pro blikání
	var shader = ShaderMaterial.new()
	shader.shader = Shader.new()
	shader.shader.code = '''
		shader_type spatial;
		render_mode unshaded, cull_disabled, depth_draw_never;

		void fragment() {
			float flicker = sin(TIME * 3.0 + UV.x * 10.0) * 0.5 + 0.5;
			ALBEDO = vec3(1.0);
			ALPHA = flicker;
		}
	'''
	mm.mesh.material = shader

	for i in STAR_COUNT:
		var pos = get_random_position_between()
		var xform = Transform3D()
		xform.origin = pos
		var scale_factor = randf_range(0.1, 1.0) # hvězdy budou různě velké
		xform.basis = Basis.IDENTITY.scaled(Vector3.ONE * scale_factor)
		mm.set_instance_transform(i, xform)

func get_random_position_between():
	while true:
		var v = Vector3(randf_range(-1,1), randf_range(-1,1), randf_range(-1,1))
		if v.length() > 0.1:
			v = v.normalized()
			var dist = STAR_FIELD_RADIUS
			return v * dist
