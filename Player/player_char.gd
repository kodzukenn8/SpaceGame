#Player Script
extends CharacterBody3D

#Player settings
const JUMP_VELOCITY = 4.5
const SENS = .005
@export var speed: int = 8
@export var health: int = 150
@export var gravity: float = 9.8

@onready var head=$head
@onready var camera=$head/Camera3D
@onready var ray_cast: RayCast3D = $head/Camera3D/RayCast3D

@onready var right_hand: Node3D = $head/Camera3D/right_hand
@export var right_hand_item : item_resource
var right_hand_empty: bool = true

@onready var left_hand: Node3D = $"head/Camera3D/left hand"
@export var left_hand_item : item_resource
var left_hand_empty :bool = true

#UI features
@onready var crosshair: TextureRect = $head/Camera3D/CanvasLayer/Crosshair
@export var default_ch = Texture2D
@export var interact_ch = Texture2D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	#cross hair logic
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if collider.is_in_group("can_interact"):
			crosshair.texture = interact_ch
		else:
			crosshair.texture = default_ch
	else:
		crosshair.texture = default_ch
	
	# Right hand and left hand pickup interaction logic, leads to pickup function.
	if Input.is_action_just_pressed("right_click") and right_hand_empty == true:
		pickup_item_hand(true)
	if Input.is_action_just_pressed("left_click") and left_hand_empty == true:
		pickup_item_hand(false)
	
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
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x=lerp(velocity.x, direction.x * speed, delta * 2.0)
		velocity.z=lerp(velocity.z, direction.z * speed, delta * 2.0)
	move_and_slide()
	
func pickup_item_hand(hand:bool):
	var item = ray_cast.get_collider()
	if item == null:
		return
	var root_item = item.get_owner()
	if not item.has_method("get_item_data"):
		return

	var current_item_data = item.item_data
	
	var mesh_inst = MeshInstance3D.new()
	if not current_item_data.mesh:
		return
	else:
		mesh_inst.mesh = current_item_data.mesh
		mesh_inst.scale = Vector3.ONE * current_item_data.item_scale_mesh
	
	if item.is_in_group("can_pickup"):
		if hand == true:
			right_hand.add_child(mesh_inst)
			root_item.get_parent().remove_child(root_item)
			right_hand_item = current_item_data
			right_hand_empty = false
		else:
			left_hand.add_child(mesh_inst)
			root_item.get_parent().remove_child(root_item)
			left_hand_item = current_item_data
			left_hand_empty = false
			
func putdown_item():
	pass
