extends StaticBody3D

@export var item_data : item_resource
var item_mesh : Mesh
var mesh_inst : MeshInstance3D

func _ready() -> void:
	if item_data and item_data.mesh:
		item_mesh = item_data.mesh
		mesh_inst = MeshInstance3D.new()
		mesh_inst.mesh = item_mesh
		mesh_inst.scale = Vector3.ONE * item_data.item_scale_mesh
		add_child(mesh_inst)

func get_item_data():
	pass
