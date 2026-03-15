extends Interactable

@onready var mesh_instance: MeshInstance3D = $mesh/Sphere

enum State{IDLE, HELD}
var state: State

var current_type: Dictionary

var move_tween: Tween

var pool = {}

var file_path = "res://resources/data/egg_types.json"
var egg_types: Dictionary

func _ready():
	randomize()
	
	_add_to_group(self)
	
	state = State.IDLE
	egg_types = Manager.get_file_contents(file_path)
	
func _pick_egg() -> String:
	var total_weight = 0

	for key in egg_types.keys():
		var chance = egg_types[key].chance
		pool[key] = chance
	
	for chance in pool.values(): 
		total_weight += chance
	
	var roll = randi_range(1, total_weight)
	
	var cumulative_weight = 0
	for egg in pool:
		cumulative_weight += pool[egg]
		
		if roll <= cumulative_weight:
			return egg
			
	return "red"

func setup(colour):
	block_click = false
	block_hover = false
	
	state = State.IDLE
	
	await get_tree().process_frame
	
	current_type = egg_types[colour]
	
	var material = mesh_instance.get_surface_override_material(0)
	material.albedo_color = Color.html(current_type.colour)
	
	self.hover_text = "[Value: £%.2f] %s Egg" % [get_sell_value(), colour.capitalize()]

func get_sell_value():
	return current_type.value
	
func get_type():
	return current_type.type
	
func get_weight():
	return current_type.weight

func start_hover():
	pass
	
func exit_hover():
	pass
	
func clicked():
	match state:
		0:
			Manager.start_hold_egg(self)
			state = State.HELD
		1:
			Manager.cancel_hold_egg()
			state = State.IDLE
