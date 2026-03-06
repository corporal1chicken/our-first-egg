extends Interactable

@onready var mesh_instance: MeshInstance3D = $mesh/Sphere

const GROUND_POSITION = Vector3(1.4, 0.3, 1.5)

enum State{IDLE, HELD}

var current_type: Dictionary
var current_state: State

var move_tween: Tween

var pool = {}

var file_path = "res://resources/data/egg_types.json"
var new_egg_types: Dictionary

func _ready():
	randomize()
	
	_add_to_group(self)
	
	current_state = State.IDLE
	new_egg_types = Manager.get_file_contents(file_path)
	
	Signals.upgrade_bought.connect(_on_upgrade_bought)

func tween_egg(property: String, change, duration: float):
	if move_tween and move_tween.is_running():
		move_tween.kill()
	
	move_tween = create_tween()
	
	move_tween.tween_property(self, property, change, duration).set_trans(Tween.TRANS_SINE)

func _pick_egg() -> String:
	var total_weight = 0

	for key in new_egg_types.keys():
		var chance = new_egg_types[key].chance
		pool[key] = chance
	
	for chance in pool.values(): 
		total_weight += chance
	
	var roll = randi_range(1, total_weight)
	
	var c = 0
	for egg in pool:
		c += pool[egg]
		
		if roll <= c:
			return egg
			
	return "red"

func setup():
	await get_tree().process_frame
	
	var chosen_egg = _pick_egg()
	current_type = new_egg_types[chosen_egg]
	
	var material = mesh_instance.get_surface_override_material(0)
	material.albedo_color = Color.html(current_type.colour)
	
	self.hover_text = "[Value: £%.2f] %s Egg" % [get_sell_value(), chosen_egg.capitalize()]
	
	tween_egg("position", GROUND_POSITION, 1.0)

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
	match current_state:
		0:
			if Manager.holding_egg: return
			Manager.start_hold_egg()
			current_state = State.HELD
		1:
			Manager.cancel_hold_egg()
			current_state = State.IDLE

func _on_upgrade_bought(_key: String):
	#if key == "value":
	#	for type in egg_types.keys():
	#		egg_types[type].value *= 1.5
	pass
