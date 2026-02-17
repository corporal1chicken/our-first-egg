extends Interactable

@export_category("Egg")
@export var egg_types: Dictionary[String, Dictionary]

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

const NEW_POSITION = Vector3(0.2, 0.3, 1.0)
const STARTING_OFFSET = Vector3(0.0, 4.0, 0.0)
const DEFAULT_TWEEN_DURATION: float = 1.0

var current_type: Dictionary

func _ready():
	_add_to_group(self)
	
func _change_colour(colour: Color):
	var material = mesh_instance.get_surface_override_material(0)
	material.albedo_color = colour

func tween_egg(property: String, change, duration: float):
	var tween = create_tween()
	
	tween.tween_property(self, property, change, duration or DEFAULT_TWEEN_DURATION).set_trans(Tween.TRANS_SINE)
	await tween.finished

func spawn_egg():
	var chosen_egg = egg_types.keys().pick_random()
	
	current_type = egg_types[chosen_egg]
	_change_colour(current_type.colour)
	
	var starting_position = NEW_POSITION + STARTING_OFFSET
	self.position = starting_position
	
	#var tween = create_tween()
	
	#tween.tween_property(self, "position", NEW_POSITION, 1.0)
	tween_egg("position", NEW_POSITION, 1.0)

func get_sell_value():
	return current_type.value
	
func get_type():
	return current_type.type

func start_hover():
	pass
	
func exit_hover():
	pass
	
func clicked():
	if Manager.holding_egg: return
	
	Manager.set_holding_egg()
