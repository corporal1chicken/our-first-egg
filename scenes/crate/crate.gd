extends Interactable

@export_category("Crate")
@export var accepts: String
@export var current_fill: int = 0
@export var max_capacity: int = 4
@export var crate_value: float = 0.0
@export var hover_position: Vector3
@export var default_position: Vector3
@export var item_position: Vector3

@onready var display_eggs: Node3D = $eggs

enum CrateState{FILLING, SELLING}

var crate_state: CrateState

var move_tween: Tween

var mouse_hovering: bool = false
var busy: bool = false

var autosell: bool = false

func _ready():
	_add_to_group(self)
	
	default_position = self.position
	crate_state = CrateState.FILLING
	
	_update_text()
	
	Signals.start_hold_egg.connect(_on_start_hold)
	Signals.end_hold_egg.connect(_on_end_hold)
	Signals.upgrade_bought.connect(_on_upgrade_bought)
	
func _hover_state():
	var target_position = hover_position if mouse_hovering else default_position
	
	if move_tween and move_tween.is_running():
		move_tween.kill()
	
	move_tween = create_tween()
	move_tween.tween_property(self, "position", target_position, 0.3)

func _update_text():
	$current_value.text = "[%d/%d] Value: £%s0" % [current_fill, max_capacity, str(crate_value)]
	$sell_receipt.text = "+£%s0" % str(crate_value)
	
func _check_if_full(weight) -> bool:

	if max_capacity == current_fill:
		hover_text = "[FULL] %s" % hover_text
		
		if autosell: 
			selling()
			hover_text = "%s Crate" % accepts.capitalize()
		
		return true
	elif weight > max_capacity - current_fill:
		hover_text = "%s Crate" % accepts.capitalize()
		return true
	else:
		return false
	
func _show_egg():
	var found_egg = display_eggs.get_node_or_null(str(current_fill))
	
	if found_egg == null:
		return
	
	var sphere = found_egg.get_node("Sphere")
	var material_clone = sphere.get_surface_override_material(0).duplicate()
	material_clone.albedo_color = Manager.egg.current_type.colour
	sphere.set_surface_override_material(0, material_clone)
	found_egg.visible = true
	
func selling():
	if busy: return
	busy = true
	block_click = true
	Manager.change_money("add", crate_value)

	$AnimationPlayer.play("sell_receipt")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("RESET")
	
	current_fill = 0
	crate_value = 0.0
	
	for egg in display_eggs.get_children(): egg.visible = false
	
	_update_text()
	busy = false
	block_click = false
	_hover_state()
	
func _filling():
	if busy: return
	if not Manager.holding_egg: return
	
	var weight = Manager.egg.get_weight()
	var multiplier: float = 1.0
	
	if _check_if_full(weight): 
		return
	
	if accepts != Manager.egg.get_type():
		multiplier = 0.5
	
	crate_value += Manager.egg.get_sell_value() * multiplier
	current_fill += weight
	
	_update_text()
	_show_egg()
	
	Manager.end_hold_egg()
	
	_check_if_full(weight)
	
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
	$red_outline.visible = true
	crate_state = CrateState.FILLING
	
func _on_end_hold():
	$red_outline.visible = false
	crate_state = CrateState.SELLING

func _on_upgrade_bought(key: String):
	if key == "storage":
		max_capacity += 4 if self.accepts != "special" else 0
		_update_text()
	elif key == "autosell":
		autosell = true
