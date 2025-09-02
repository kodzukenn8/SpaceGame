extends StaticBody3D

@onready var soda_ui: CanvasLayer = $SodaUI
@onready var slots : Array
@onready var timers: Array
@onready var current_soda: Array
@onready var slots_filled: Array
@onready var player_looking_at
@onready var current_slot

@onready var itemResBlank = preload("res://Scenes/item_resource_blank.tscn")
#soda resources
@onready var lime_soda : item_resource = preload("res://Scenes/Items/soda_cup/lime_soda/res_lime_soda.tres")
@onready var cola_soda : item_resource = preload("res://Scenes/Items/soda_cup/cola_soda/res_cola_soda.tres")
@onready var grape_soda : item_resource = preload("res://Scenes/Items/soda_cup/grape_soda/res_grape_soda.tres")
@onready var orange_soda : item_resource = preload("res://Scenes/Items/soda_cup/orange_soda/res_orange_soda.tres")

func _ready() -> void:
		slots = [
			$cupSlots/Slot1,
			$cupSlots/Slot2,
			$cupSlots/Slot3,
			$cupSlots/Slot4
			]
		timers = [
			$cupSlots/Slot1/S1Timer,
			$cupSlots/Slot2/S2Timer,
			$cupSlots/Slot3/S3Timer,
			$cupSlots/Slot4/S4Timer
			]
		current_soda = [
			null,
			null,
			null,
			null
			]
		slots_filled = [
			false,
			false,
			false,
			false
			]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_player_place_soda_slot(item_res: item_resource,slotnum) -> void:
	slotnum= int(slotnum)
	var mesh_inst = MeshInstance3D.new()
	mesh_inst.mesh = item_res.mesh
	mesh_inst.scale = Vector3.ONE * item_res.item_scale_mesh
	var slot_ = slots[slotnum - 1]
	slot_.add_child(mesh_inst)
	slots_filled[slotnum-1] = true

func _on_player_open_soda_ui(player_looking_at):
	soda_ui.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var slot_player = player_looking_at.name
	current_slot = slot_player.substr(3,1)
	current_slot = int(current_slot)
	print(current_slot)

func _on_exit_pressed() -> void:
	soda_ui.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_lime_pressed() -> void:
	if slots_filled[current_slot-1] == true:
		current_soda[current_slot-1]=lime_soda
		timers[current_slot-1].start()
		soda_ui.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		return

func _on_cola_pressed() -> void:
	if slots_filled[current_slot-1] == true:
		current_soda[current_slot-1]=cola_soda
		timers[current_slot-1].start()
		soda_ui.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		return

func _on_grape_pressed() -> void:
	if slots_filled[current_slot-1] == true:
		current_soda[current_slot-1]=grape_soda
		timers[current_slot-1].start()
		soda_ui.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		return

func _on_orange_pressed() -> void:
	if slots_filled[current_slot-1] == true:
		current_soda[current_slot-1]=orange_soda
		timers[current_slot-1].start()
		soda_ui.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		return

func _on_s_1_timer_timeout() -> void:
	_drink_poured(0)
func _on_s_2_timer_timeout() -> void:
	_drink_poured(1)
func _on_s_3_timer_timeout() -> void:
	_drink_poured(2)
func _on_s_4_timer_timeout() -> void:
	_drink_poured(3)

func _drink_poured(slotnum):
	var slot_used=slots[slotnum]
	for child in slot_used.get_children():
		if child is MeshInstance3D:
			slot_used.remove_child(child)
			child.queue_free()
	var new_soda = itemResBlank.instantiate()
	new_soda.item_data = current_soda[slotnum]
	slot_used.add_child(new_soda)
