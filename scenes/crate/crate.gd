extends Interactable

@export_category("Crate")
@export var current_fill: int = 0
@export var max_capacity: int = 4
@export var crate_value: float = 0.0
@export var hover_position: Vector3
@export var default_position: Vector3
@export var item_position: Vector3
@export var min_size: int = 2
@export var max_size: int = 4

@onready var display_eggs: Node3D = $eggs

enum CrateState{FILLING, SELLING}

var crate_state: CrateState

var move_tween: Tween
var mouse_hovering: bool = false
var busy: bool = false
var autosell: bool = false
var sell_multiplier: float = 1.0
var actual_amount: int = 0
var file_path: String = "res://resources/data/egg_types.json"
var pool: Dictionary
var current_order: Array
var emoji_text: Array
var can_sell: bool = true
var streak_broken: bool = false

func _ready():
	_add_to_group(self)
	
	default_position = self.position
	crate_state = CrateState.SELLING
	
	_update_text()
	max_capacity = 0
	
	pool = Manager.get_file_contents(file_path)
		
	_create_order()
	
	Signals.start_hold_egg.connect(_on_start_hold)
	Signals.end_hold_egg.connect(_on_end_hold)
	Signals.upgrade_bought.connect(_on_upgrade_bought)
	Signals.game_started.connect(_create_order)

func _get_random_egg():
	var total_weight = 0
	
	for key in pool.keys(): 
		total_weight += pool[key].chance
	
	var roll = randi_range(1, total_weight)
	
	var c = 0
	for egg in pool:
		c += pool[egg].chance
		
		if roll <= c:
			return egg
			
	return "red"
	
func _create_order():
	var amount = randi_range(min_size, max_size)
	
	current_order = []
	emoji_text = []
	max_capacity = 0
	
	for i in range(amount):
		var egg = _get_random_egg()
		
		current_order.append(pool[egg].type)
		emoji_text.append(pool[egg].emoji)
		max_capacity += pool[egg].weight
	
	_update_text()
	can_sell = true
	
func _hover_state():
	var target_position = hover_position if mouse_hovering else default_position
	
	if move_tween and move_tween.is_running():
		move_tween.kill()
	
	move_tween = create_tween()
	move_tween.tween_property(self, "position", target_position, 0.3)

func _update_text():
	$current_value.text = "[%d/%d] Value: £%.2f" % [current_fill, max_capacity, crate_value]
	$sell_receipt.text = "+£%.2f" % (crate_value * sell_multiplier)
	$order.text = ", ".join(emoji_text)
		
func _check_if_full(weight) -> bool:
	if max_capacity == current_fill:
		return true
	elif weight > max_capacity - current_fill:
		return true
		
	return false
	
func _show_egg(value: float):
	var found_egg = display_eggs.get_node_or_null(str(actual_amount))
	
	if found_egg == null:
		return
	
	var sphere = found_egg.get_node("Sphere")
	var label = found_egg.get_node("multipler")
	var material_clone = sphere.get_surface_override_material(0).duplicate()
	material_clone.albedo_color = Manager.egg.current_type.colour
	sphere.set_surface_override_material(0, material_clone)
	found_egg.visible = true
	label.text = "%sx" % str(value)
	
	if value == 1.0:
		label.modulate = Color.html("#2af527")
	elif value == 1.2:
		label.modulate = Color.html("#ffb33d")
	else:
		label.modulate = Color.html("#fb003a")

func _reset_crate():
	pass

func selling():	
	if busy: return
	if current_fill != max_capacity: return
	
	if not can_sell: return
	
	busy = true
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
	
	$current_value.visible = false
	
	current_fill = 0
	crate_value = 0.0
	actual_amount = 0
	Manager.crates_sold += 1
	
	#for egg in display_eggs.get_children(): egg.visible = false

	busy = false
	block_click = false
	can_sell = false
	$order.text = "COMPLETE"
	
	_hover_state()
	
func _filling():
	if not can_sell: return
	if busy: return
	if not Manager.holding_egg: return
	
	var weight = Manager.egg.get_weight()
	var type = Manager.egg.get_type()
	var sell_value = Manager.egg.get_sell_value()
	var multiplier: float = 1.0
	
	if _check_if_full(weight): 
		return
	
	if current_order.has(type):
		if current_order[0] == type:
			if not streak_broken:
				Signals.debug_signal.emit("is first")
			
				multiplier = 1.2
		else:
			Signals.debug_signal.emit("streak_broken")
			streak_broken = true
		
		current_order.erase(type)
		emoji_text.erase(pool[type].emoji)
	else:
		multiplier = 0.5
	
	crate_value += sell_value * multiplier
	current_fill += weight
	
	actual_amount += 1
	
	_update_text()
	_show_egg(multiplier)
	
	Manager.end_hold_egg()
	
	busy = false
	block_click = false
	
	_hover_state()
	
func clicked():
	if busy: return
	
	match crate_state:
		0: _filling()
		1: selling()
	
func start_hover():
	mouse_hovering = true
	
	if Manager.holding_egg: $red_outline.visible = false
	
	$white_outline.visible = true
	_hover_state()
	
func exit_hover():
	mouse_hovering = false
	if Manager.holding_egg: 
		$red_outline.visible = true 
	
	$white_outline.visible = false
	_hover_state()
	
func _on_start_hold():
	if current_order.has(Manager.egg.get_type()):
		$red_outline.visible = true
		
	crate_state = CrateState.FILLING
	
func _on_end_hold():
	$red_outline.visible = false
	crate_state = CrateState.SELLING

func _on_upgrade_bought(key: String):
	#if key == "storage":
	#	max_capacity += 4 if self.accepts != "special" else 0
	#	_update_text()
	#elif key == "autosell":
	#	autosell = true
	#elif key == "bonus":
	#	sell_multiplier = 2.0
	
	if key == "autosell":
		autosell = true
	elif key == "size":
		min_size = 4
		max_size = 7
	
	pass
