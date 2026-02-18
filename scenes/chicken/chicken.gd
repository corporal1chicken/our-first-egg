extends Interactable

func _ready():
	_add_to_group(self)

func start_hover():
	pass
	
func exit_hover():
	pass
	
func clicked():
	Manager.create_egg()
