extends Interactable

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
	
	Signals.is_holding_egg.connect(_on_holding_egg)
	Signals.finished_holding_egg.connect(_on_finished_holding_egg)

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
	if Manager.holding_egg: red_outline.visible = true
	
	white_outline.visible = false
	_hover_actions("exit")
	
func _selling():
	Manager.add_money(sell_value)
	current_fill = 0
	sell_value = 0.0
	$current_value.text = "[0/%d] Value: £0.00" % [max_capacity]
	
func _filling():
	if not Manager.holding_egg: return
	if not is_hovering: return
	if is_full: return
	
	block_hover = true
	block_click = true
	
	await Manager.egg_scene.tween_egg("position", item_position.global_position, 0.8)
	
	var multiplier: float = 1.0
	
	if accepts != Manager.egg_scene.get_type():
		multiplier = 0.5
	
	sell_value += Manager.egg_scene.get_sell_value() * multiplier
	current_fill += 1
	
	if current_fill >= max_capacity: is_full = true
	
	$current_value.text = "[%d/%d] Value: £%s0" % [current_fill, max_capacity, str(sell_value)]
	
	Manager.clear_egg()
	block_hover = false
	block_click = false
	
func clicked():
	match current_state:
		0:
			_filling()
		1:
			_selling()

func _on_holding_egg():
	red_outline.visible = true
	current_state = State.FILLING

func _on_finished_holding_egg():
	red_outline.visible = false
	current_state = State.SELLING
