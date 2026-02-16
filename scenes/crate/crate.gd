extends Interactable

@onready var outline: Node3D = $outline

func _ready():
	_add_to_group(self)

func start_hover():
	outline.visible = true
	
func exit_hover():
	outline.visible = false
	
func clicked():
	print("clicked crate")
