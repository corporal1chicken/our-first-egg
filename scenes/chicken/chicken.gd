extends Interactable

@export_category("Chicken")
@export var egg: PackedScene

var egg_spawned: bool = false

func _ready():
	_add_to_group(self)

func start_hover():
	print("hovering %s" % self.name)
	
func exit_hover():
	print("left hovering %s" % self.name)
	
func clicked():
	if egg_spawned: return
	
	var clone: Interactable = egg.instantiate()
	get_tree().current_scene.add_child(clone)
	
	Manager.egg_scene = clone
	
	egg_spawned = true
	clone.call("spawn_egg")
