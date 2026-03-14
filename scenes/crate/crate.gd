extends Interactable

# Config
@export_category("Crate")
@export var crate_value: float = 0.0
@export var hover_position: Vector3
@export var default_position: Vector3
@export var item_position: Vector3
@export var min_size: int = 2
@export var max_size: int = 4
@export var colours: Dictionary[float, String]

# Onready
@onready var display_eggs: Node3D = $eggs

# State
enum State{FILLING, SELLING}
var state: State = State.FILLING

# Constants
const FILE_PATH: String = "res://resources/data/egg_types.json"

# Flags
var mouse_hovering: bool = false
var autosell: bool = false
var already_sold: bool = false
var streak_broken: bool = false

# Crate Specific
var sell_multiplier: float = 1.0
var actual_fill: int = 0
var max_capacity: int = 0
var current_fill: int = 0

var pool: Dictionary
var current_order: Array
var emoji_text: Array

# Extra
var move_tween: Tween

# Built In
func _ready():
	# Setting variables
	default_position = self.position
	pool = Manager.get_file_contents(FILE_PATH)
	
	# Connecting signals
	Signals.start_hold_egg.connect(_holding_egg)
	Signals.end_hold_egg.connect(_cancel_hold)
	Signals.upgrade_bought.connect(_on_upgrade_bought)
	Signals.start_round.connect(_create_order)
	Signals.game_started.connect(_create_order)

# Helper Functions
func _pick_egg():
	var total_weight = 0
	
	for key in pool.keys(): 
		total_weight += pool[key].chance
	
	var roll = randi_range(1, total_weight)
	var cumulative_weight = 0
	
	for egg in pool:
		cumulative_weight += pool[egg].chance
		
		if roll <= cumulative_weight:
			return egg
			
	return "red"
	
func _tween_hover():
	var target_position = hover_position if mouse_hovering else default_position
	
	if move_tween and move_tween.is_running():
		move_tween.kill()
	
	move_tween = create_tween()
	move_tween.tween_property(self, "position", target_position, 0.3)

func _update_labels():
	$current_value.text = "[%d/%d] Value: £%.2f" % [current_fill, max_capacity, crate_value]
	$sell_receipt.text = "+£%.2f" % (crate_value * sell_multiplier)
	$order.text = ", ".join(emoji_text)
	
func _check_capacity(weight):
	if max_capacity == current_fill:
		return true
	elif weight > max_capacity - current_fill:
		return true
	
	return false
	
func _show_egg(value):
	var found_egg = display_eggs.get_node_or_null(str(actual_fill))
	
	if found_egg == null:
		return
	
	var sphere = found_egg.get_node("Sphere")
	var label = found_egg.get_node("multipler")
	var material_clone = sphere.get_surface_override_material(0).duplicate()
	material_clone.albedo_color = Manager.egg.current_type.colour
	sphere.set_surface_override_material(0, material_clone)
	found_egg.visible = true
	
	label.text = "%sx" % str(value)
	label.modulate = Color.html(colours[value])

# Main Logic
func _reset_crate():
	current_fill = 0
	actual_fill = 0
	
	current_order = []
	emoji_text = []
	already_sold = false
	streak_broken = false
	
	block_click = false
	
	$current_value.visible = true

func _create_order():
	_reset_crate()
	
	var amount = randi_range(min_size, max_size)
	
	max_capacity = 0
	
	for i in range(amount):
		var egg = _pick_egg()
		
		current_order.append(pool[egg].type)
		emoji_text.append(pool[egg].emoji)
		max_capacity += pool[egg].weight
	
	_update_labels()

func _selling():
	if current_fill != max_capacity: return
	if already_sold: return
	
	block_click = true
	
	Manager.change_money("add", crate_value)
	$current_value.visible = false
	$order.text = "SELLING"
	
	for egg in display_eggs.get_children():
		if not egg.visible: continue
		
		var sphere = egg.get_node("Sphere")
		var label = egg.get_node("multipler")
		var material = sphere.get_surface_override_material(0)
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(material, "albedo_color:a", 0.0, 0.3)
		tween.tween_property(label, "modulate:a", 0.0, 0.3)
		await tween.finished
	
	$AnimationPlayer.play("sell_receipt")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("RESET")
	
	$order.text = "COMPLETE"
	
	current_fill = 0
	crate_value = 0.0
	actual_fill = 0
	Manager.crates_sold += 1
	Manager.check_end_round()

	block_click = false
	already_sold = true
	
	#_hover_state()
	
func _filling():
	if not Manager.holding_egg: return
	
	block_click = true
	
	var weight = Manager.egg.get_weight()
	var type = Manager.egg.get_type()
	var sell_value = Manager.egg.get_sell_value()
	var multiplier: float = 1.0
	
	if _check_capacity(weight): 
		return
	
	if current_order.has(type):
		if current_order[0] == type:
			if not streak_broken:
			#	Signals.debug_signal.emit("is first")
			
				multiplier = 1.2
		else:
			#Signals.debug_signal.emit("streak_broken")
			streak_broken = true
		
		current_order.erase(type)
		emoji_text.erase(pool[type].emoji)
	else:
		multiplier = 0.5
	
	crate_value += sell_value * multiplier
	current_fill += weight
	
	actual_fill += 1
	
	_update_labels()
	_show_egg(multiplier)
	
	Manager.end_hold_egg()
	
	block_click = false

# Interactable Required
func clicked():
	match state:
		0: _filling()
		1: _selling()
	
func start_hover():
	mouse_hovering = true
	if Manager.holding_egg: $red_outline.visible = false
	
	$white_outline.visible = true
	_tween_hover()
	
func exit_hover():
	mouse_hovering = false
	if Manager.holding_egg: $red_outline.visible = true 
	
	$white_outline.visible = false
	_tween_hover()

# Signal Connections
func _holding_egg():
	if current_order.has(Manager.egg.get_type()):
		$red_outline.visible = true
		
	state = State.FILLING
	
func _cancel_hold():
	$red_outline.visible = false
	state = State.SELLING
	
func _on_upgrade_bought(key: String):
	pass
