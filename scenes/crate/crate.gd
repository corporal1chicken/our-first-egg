extends Interactable

@export_category("Crate")
@export var accepts: String
@export var current_fill: int = 0
@export var max_capacity: int = 4
@export var crate_value: float = 0.0
@export var hover_position: Vector3
@export var default_position: Vector3
@export var item_position: Vector3

enum CrateState{FILLING, SELLING}

var crate_state: CrateState

var move_tween: Tween

var mouse_hovering: bool = false
var busy: bool = false

func _ready():
	_add_to_group(self)
	
	default_position = self.position
	crate_state = CrateState.FILLING
	
	_update_text()
	
	Signals.start_hold_egg.connect(_on_start_hold)
	Signals.end_hold_egg.connect(_on_end_hold)
	
func _hover_state():
	var target_position = hover_position if mouse_hovering else default_position
	
	if move_tween and move_tween.is_running():
		move_tween.kill()
	
	move_tween = create_tween()
	move_tween.tween_property(self, "position", target_position, 0.3)

func _update_text():
	$current_value.text = "[%d/%d] Value: £%s0" % [current_fill, max_capacity, str(crate_value)]
	$sell_receipt.text = "+£%s0" % str(crate_value)
	
func _check_if_full() -> bool:
	return true if max_capacity == current_fill else false
	
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
	
	_update_text()
	busy = false
	block_click = false
	_hover_state()
	
func _filling():
	if busy: return
	if not Manager.holding_egg: return
	if _check_if_full(): return
	
	await Manager.egg.tween_egg("position", $Node3D.global_position, 0.8)
	
	var multiplier: float = 1.0
	
	if accepts != Manager.egg.get_type():
		multiplier = 0.5
	
	crate_value += Manager.egg.get_sell_value() * multiplier
	current_fill += 1
	
	_update_text()
	
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
	$red_outline.visible = true
	crate_state = CrateState.FILLING
	
func _on_end_hold():
	$red_outline.visible = false
	crate_state = CrateState.SELLING

"""
@export_category("Crate")
@export var accepts: String
@export var is_full: bool = false
@export var current_fill: int = 0
@export var max_capacity: int = 4
@export var sell_value: float = 0.0
@export var hover_position: Vector3
@export var default_position: Vector3

@onready var white_outline: Node3D = $white_outline
@onready var red_outline: Node3D = $red_outline
@onready var item_position: Node3D = $item_position

enum State{FILLING, SELLING}

var is_hovering: bool = false
var current_state: State

func _ready():
	_add_to_group(self)
	
	$current_value.text = "[0/%d] Value: £0.00" % [max_capacity]
	
	default_position = self.position
	current_state = State.SELLING
	
	Signals.start_hold_egg.connect(_on_holding_egg)
	Signals.end_hold_egg.connect(_on_finished_holding_egg)
	Signals.sell_crates.connect(_selling)

func _tween_crate(property: String, change, duration):
	var tween = create_tween()
	tween.tween_property(self, property, change, duration)
	
	await tween.finished
	
func _hover_actions(action: String):
	block_hover = true
	block_click = true
	
	match action:
		"start":
			is_hovering = true
			await _tween_crate("position", hover_position, 0.4)
		"exit":
			is_hovering = false
			await _tween_crate("position", default_position, 0.4)
			
	block_hover = false
	block_click = false

func start_hover():
	if Manager.holding_egg: red_outline.visible = false
	
	white_outline.visible = true
	_hover_actions("start")
	
func exit_hover():
	if Manager.holding_egg: 
		red_outline.visible = true
		return
	
	white_outline.visible = false
	_hover_actions("exit")
	
func _sell_receipt():
	$sell_receipt.text = "+£%s0" % str(sell_value)
	$AnimationPlayer.play("sell_receipt")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("RESET")
	
func _selling():
	Manager.change_money("add", sell_value)
	
	_sell_receipt()
	
	current_fill = 0
	sell_value = 0.0
	$current_value.text = "[0/%d] Value: £0.00" % [max_capacity]
	
func _filling():
	if not Manager.holding_egg: return
	if not is_hovering: return
	if is_full: return
	
	block_hover = true
	block_click = true
	
	await Manager.egg.tween_egg("position", item_position.global_position, 0.8)
	
	var multiplier: float = 1.0
	
	if accepts != Manager.egg.get_type():
		multiplier = 0.5
	
	sell_value += Manager.egg.get_sell_value() * multiplier
	current_fill += 1
	
	if current_fill >= max_capacity: is_full = true
	
	$current_value.text = "[%d/%d] Value: £%s0" % [current_fill, max_capacity, str(sell_value)]
	
	Manager.end_hold_egg()
	_hover_actions("exit")
	block_hover = false
	block_click = false
	
func clicked():
	match current_state:
		0: _filling()
		1: _selling()

func _on_holding_egg():
	red_outline.visible = true
	current_state = State.FILLING
	_hover_actions("start")
	block_hover = true

func _on_finished_holding_egg():
	red_outline.visible = false
	current_state = State.SELLING
	_hover_actions("exit")
	block_hover = false
"""
