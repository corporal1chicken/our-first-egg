extends Interactable

@export_category("Egg")
@export var egg_types: Dictionary[String, Dictionary]

@onready var mesh_instance: MeshInstance3D = $mesh/Sphere

const GROUND_POSITION = Vector3(0.28, 0.3, 1.8)

enum State{IDLE, HELD}

var current_type: Dictionary
var current_state: State

var move_tween: Tween

var pool = {}

func _ready():
	randomize()
	
	_add_to_group(self)
	
	current_state = State.IDLE
	
	Signals.upgrade_bought.connect(_on_upgrade_bought)

func tween_egg(property: String, change, duration: float):
	if move_tween and move_tween.is_running():
		move_tween.kill()
	
	move_tween = create_tween()
	
	move_tween.tween_property(self, property, change, duration).set_trans(Tween.TRANS_SINE)
	#await move_tween.finished

func _pick_egg() -> String:
	var total_weight = 0
	
	pool["regular"] = egg_types["regular"].chance
	pool["yellow"] = egg_types["yellow"].chance
	pool["burnt"] = egg_types["burnt"].chance
	
	if Manager.special_unlocked:
		pool["special"] = egg_types["special"].chance
	
	for chance in pool.values(): 
		total_weight += chance
	
	var roll = randi_range(1, total_weight)
	
	var c = 0
	for egg in pool:
		c += pool[egg]
		
		if roll <= c:
			return egg
			
	return "regular"

func setup():
	await get_tree().process_frame
	
	var chosen_egg = _pick_egg()
	current_type = egg_types[chosen_egg]
	
	var material = mesh_instance.get_surface_override_material(0)
	material.albedo_color = current_type.colour
	
	self.hover_text = "[Value: £%s0] %s Egg" % [str(get_sell_value()), chosen_egg.capitalize()]
	
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

func _on_upgrade_bought(key: String):
	if key == "value":
		for type in egg_types.keys():
			egg_types[type].value *= 1.5
