extends Interactable

func _ready():
	_add_to_group(self)
	
	Signals.spawn_egg.connect(_spawn_egg)
	
func _spawn_egg(new_position: Vector3):
	var starting_position = new_position + Vector3(0.0, 4.0, 0.0)
	self.position = starting_position
	
	var tween = create_tween()
	
	tween.tween_property(self, "position", new_position, 1.0).from(starting_position)
	
func start_hover():
	pass
	
func exit_hover():
	pass
	
func clicked():
	pass
