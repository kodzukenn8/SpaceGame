#Player Script
extends CharacterBody3D

#Player settings
const JUMP_VELOCITY = 4.5
const SENS = .005
@export var speed: int = 8
@export var health: int = 150
@export var gravity: float = 9.8
@onready var player_char: CharacterBody3D = $"."

@onready var head=$head
@onready var camera=$head/Camera3D
@onready var ray_cast: RayCast3D = $head/Camera3D/RayCast3D

@onready var right_hand: Node3D = $head/Camera3D/right_hand
var rh_item_data : item_resource
var right_hand_empty: bool = true
var rh_item : MeshInstance3D

@onready var left_hand: Node3D = $"head/Camera3D/left hand"
var lh_item_data : item_resource
var left_hand_empty :bool = true
var lh_item : MeshInstance3D

#UI features
@onready var crosshair: TextureRect = $head/Camera3D/CanvasLayer/Crosshair
@export var default_ch = Texture2D
@export var interact_ch = Texture2D
@onready var leftclick: Label = $head/Camera3D/CanvasLayer/Leftclick
@onready var rightclick: Label = $head/Camera3D/CanvasLayer/Rightclick

@onready var ItemResBlank = preload("res://Scenes/item_resource_blank.tscn")


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	#cross hair logic and playable ui
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if collider.is_in_group("can_interact"):
			crosshair.texture = interact_ch
		else:
			crosshair.texture = default_ch
		if collider.is_in_group("can_pickup") and left_hand_empty == true:
			leftclick.show()
		else:
			leftclick.hide()
		if collider.is_in_group("can_pickup") and right_hand_empty == true:
			rightclick.show()
		else:
			rightclick.hide()
	else:
		crosshair.texture = default_ch
		rightclick.hide()
		leftclick.hide()
	
	# Right hand and left hand item pickup and putdown input logic
	if Input.is_action_just_pressed("right_click"):
		if right_hand_empty == true:
			rh_item = _pickup_item(right_hand_empty,true)
		else:
			_putdown_item(rh_item, true)
	if Input.is_action_just_pressed("left_click"):
		if left_hand_empty == true:
			lh_item = _pickup_item(left_hand_empty,false)
		else:
			_putdown_item(lh_item, false)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENS)
		camera.rotate_x(-event.relative.y * SENS)
		camera.rotation.x = clamp(camera.rotation.x,deg_to_rad(-90),deg_to_rad(60))
		
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
#Player jump mechanic (might delete!) 
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

#Player movement
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 5.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 5.0)
	else:
		velocity.x=lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z=lerp(velocity.z, direction.z * speed, delta * 3.0)
	move_and_slide()
	
func _pickup_item(_is_empty:bool,hand:bool):
	if _is_empty == false:
		return
	var item = ray_cast.get_collider()
	if item == null:
		return
	var root_item = item.get_parent()

	if not item.has_method("get_item_data"):
		return
	var current_item_data = item.item_data
#Instancing a new mesh
	var mesh_inst = MeshInstance3D.new()
	if not current_item_data.mesh:
		return
	else:
		mesh_inst.mesh = current_item_data.mesh
		mesh_inst.scale = Vector3.ONE * current_item_data.item_scale_mesh
#the actual "pick up" of the item
	if item.is_in_group("can_pickup") and hand == true:
		right_hand.add_child(mesh_inst)
		root_item.remove_child(item)
		rh_item_data = current_item_data
		right_hand_empty = false
		return mesh_inst
	if item.is_in_group("can_pickup") and hand == false:
		left_hand.add_child(mesh_inst)
		root_item.remove_child(item)
		lh_item_data = current_item_data
		left_hand_empty = false
		return mesh_inst

func _putdown_item(item_scene: MeshInstance3D, hand: bool) -> void:
	var collider = ray_cast.get_collider()
	if collider == null:
		return
	if not collider.is_in_group("placeable_area"):
		return
	if collider.is_in_group("placeable_area") and ray_cast.get_collision_normal().dot(Vector3.UP)>.95:
		if hand == true:
			var new_item = ItemResBlank.instantiate()
			if new_item == null:
				return
			var world = player_char.get_parent()
			new_item.item_data = rh_item_data
			new_item.position = ray_cast.get_collision_point()
			for child in right_hand.get_children():
				right_hand.remove_child(child)
				child.queue_free()
			world.add_child(new_item)
			right_hand_empty = true
			rh_item_data = null
		else:
			var new_item = ItemResBlank.instantiate()
			if new_item == null:
				return
			var world = player_char.get_parent()
			new_item.item_data = lh_item_data
			new_item.position = ray_cast.get_collision_point()
			for child in left_hand.get_children():
				left_hand.remove_child(child)
				child.queue_free()
			world.add_child(new_item)
			left_hand_empty = true
			lh_item_data = null
