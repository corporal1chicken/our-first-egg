extends Interactable

@export_category("Egg")
@export var egg_types: Dictionary[String, Dictionary]

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

const GROUND_POSITION = Vector3(0.2, 0.3, 1.0)

enum State{IDLE, HELD}

var current_type: Dictionary
var current_state: State

var move_tween: Tween

func _ready():
	_add_to_group(self)
	
	current_state = State.IDLE

func tween_egg(property: String, change, duration: float):
	if move_tween and move_tween.is_running():
		move_tween.kill()
	
	move_tween = create_tween()
	
	move_tween.tween_property(self, property, change, duration).set_trans(Tween.TRANS_SINE)
	await move_tween.finished

func setup():
	await get_tree().process_frame
	
	var chosen_egg = egg_types.keys().pick_random()
	current_type = egg_types[chosen_egg]
	
	var material = mesh_instance.get_surface_override_material(0)
	material.albedo_color = current_type.colour
	
	await tween_egg("position", GROUND_POSITION, 1.0)

func get_sell_value():
	return current_type.value
	
func get_type():
	return current_type.type

func start_hover():
	pass
	
func exit_hover():
	pass
	
func clicked():
	match current_state:
		0:
			if Manager.holding_egg: return
			Manager.start_hold_egg()
			current_state = State.HELD
		1:
			Manager.cancel_hold_egg()
			current_state = State.IDLE
