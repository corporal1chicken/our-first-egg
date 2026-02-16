extends Interactable

@export_category("Egg")
@export var egg_types: Dictionary[String, Dictionary]

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

const NEW_POSITION = Vector3(0.6, 0.5, 0.5)
const STARTING_OFFSET = Vector3(0.0, 4.0, 0.0)

func _ready():
	_add_to_group(self)
	
func _change_colour(colour: Color):
	var material = mesh_instance.get_surface_override_material(0)
	material.albedo_color = colour
	
func spawn_egg():
	var chosen_egg = egg_types.keys().pick_random()
	
	_change_colour(egg_types[chosen_egg].colour)
	
	var starting_position = NEW_POSITION + STARTING_OFFSET
	self.position = starting_position
	
	var tween = create_tween()
	
	tween.tween_property(self, "position", NEW_POSITION, 1.0).from(starting_position)
	
func start_hover():
	pass
	
func exit_hover():
	pass
	
func clicked():
	if Manager.holding_egg: return
	
	Manager.set_holding_egg()
