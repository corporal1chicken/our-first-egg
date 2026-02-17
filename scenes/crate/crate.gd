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

func _ready():
	_add_to_group(self)
	
	default_position = self.position
	
	Signals.is_holding_egg.connect(_on_holding_egg)
	Signals.finished_holding_egg.connect(_on_finished_holding_egg)

func _tween_crate(property: String, change, duration):
	var tween = create_tween()
	tween.tween_property(self, property, change, duration)
	
	await tween.finished

func start_hover():
	if Manager.holding_egg: red_outline.visible = false
	
	white_outline.visible = true
	block_hover = true
	block_click = true
	await _tween_crate("position", hover_position, 0.4)
	block_hover = false
	block_click = false
	
func exit_hover():
	if Manager.holding_egg: red_outline.visible = true
	
	white_outline.visible = false
	block_hover = true
	block_click = true
	await _tween_crate("position", default_position, 0.4)
	block_hover = false
	block_click = false
	
func clicked():
	if not Manager.holding_egg: return
	
	block_hover = true
	block_click = true
	await _tween_crate("position", hover_position, 0.4)
	await Manager.egg_scene.tween_egg("position", item_position.global_position, 0.8)
	
	var multiplier: float = 1.0
	
	if accepts != Manager.egg_scene.get_type():
		multiplier = 0.5
	
	sell_value += Manager.egg_scene.get_sell_value() * multiplier
	$current_value.text = "Value: £%s0" % str(sell_value)
	
	Manager.clear_egg()
	block_hover = false
	block_click = false

func _on_holding_egg():
	red_outline.visible = true

func _on_finished_holding_egg():
	red_outline.visible = false
