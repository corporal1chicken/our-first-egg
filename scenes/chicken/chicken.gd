extends Interactable

# Pick random egg and spawn it
# Egg click and crate logic
# Possibly dedicated manager for it

@onready var egg_position: Node3D = $egg_position

var egg_spawned: bool = false

func _ready():
	_add_to_group(self)
	print(egg_position.position)

func start_hover():
	print("hovering %s" % self.name)
	
func exit_hover():
	print("left hovering %s" % self.name)
	
func clicked():
	if egg_spawned: return
	
	egg_spawned = true
	Signals.spawn_egg.emit(Vector3(1.0, 1.0, 0.0))
