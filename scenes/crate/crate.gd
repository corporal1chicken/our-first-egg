extends Interactable

@export_category("Crate")
@export var accepts: String
@export var is_full: bool = false

@onready var white_outline: Node3D = $white_outline
@onready var red_outline: Node3D = $red_outline
@onready var item_position: Node3D = $item_position

func _ready():
	_add_to_group(self)
	
	Signals.is_holding_egg.connect(_on_holding_egg)

func start_hover():
	if Manager.holding_egg: red_outline.visible = false
	
	white_outline.visible = true
	
func exit_hover():
	if Manager.holding_egg: red_outline.visible = true
	
	white_outline.visible = false
	
func clicked():
	if not Manager.holding_egg: return
	
	var tween = create_tween()
	tween.tween_property(Manager.egg_scene, "position", item_position.global_position, 0.7)

func _on_holding_egg():
	red_outline.visible = true
