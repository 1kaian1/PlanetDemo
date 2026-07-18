extends MeshInstance3D

@export var size: float = 2
@export var resolution: int = 128
@export var radius: float = 51.0  # poloměr koule
@export var texture: Texture2D = preload("res://textures/earth_square_frame/pixil-frame-0.png")

func _ready():
	mesh = create_spherical_grid(resolution, size, radius)
	
	#var mat = StandardMaterial3D.new()
	#mat.albedo_texture = texture
	#mat.metallic = 0.0
	#mat.roughness = 0.5
	#mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	#material_override = mat
	
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = texture
	mat.emission_enabled = true
	mat.emission_texture = texture  # emise = podle textury
	mat.emission_energy = 1.5       # síla svícení
	mat.metallic = 0.0
	mat.roughness = 0.5
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	material_override = mat


func create_spherical_grid(resolution: int, size: float, radius: float) -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var half = size * 0.5
	var z_plane = 1.0  # strana krychle +Z

	for y in range(resolution - 1):
		for x in range(resolution - 1):
			var x0 = float(x)/(resolution-1) * size - half
			var x1 = float(x+1)/(resolution-1) * size - half
			var y0 = float(y)/(resolution-1) * size - half
			var y1 = float(y+1)/(resolution-1) * size - half

			# body na čtverci ve 3D
			#var p00 = Vector3(x0, y0, z_plane).normalized() * radius
			#var p10 = Vector3(x1, y0, z_plane).normalized() * radius
			#var p01 = Vector3(x0, y1, z_plane).normalized() * radius
			#var p11 = Vector3(x1, y1, z_plane).normalized() * radius

			var p00 = Vector3(x0, z_plane, y0).normalized() * radius
			var p10 = Vector3(x1, z_plane, y0).normalized() * radius
			var p01 = Vector3(x0, z_plane, y1).normalized() * radius
			var p11 = Vector3(x1, z_plane, y1).normalized() * radius


			# normály
			var n00 = p00.normalized()
			var n10 = p10.normalized()
			var n01 = p01.normalized()
			var n11 = p11.normalized()

			# UV souřadnice (jednoduché lineární mapování)
			var uv00 = Vector2(float(x)/resolution, float(y)/resolution)
			var uv10 = Vector2(float(x+1)/resolution, float(y)/resolution)
			var uv01 = Vector2(float(x)/resolution, float(y+1)/resolution)
			var uv11 = Vector2(float(x+1)/resolution, float(y+1)/resolution)

			# první trojúhelník
			st.set_normal(n00); st.set_uv(uv00); st.add_vertex(p00)
			st.set_normal(n10); st.set_uv(uv10); st.add_vertex(p10)
			st.set_normal(n11); st.set_uv(uv11); st.add_vertex(p11)

			# druhý trojúhelník
			st.set_normal(n00); st.set_uv(uv00); st.add_vertex(p00)
			st.set_normal(n11); st.set_uv(uv11); st.add_vertex(p11)
			st.set_normal(n01); st.set_uv(uv01); st.add_vertex(p01)
	
	return st.commit() as ArrayMesh
