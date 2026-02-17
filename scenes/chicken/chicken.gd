extends Interactable

@export_category("Chicken")
@export var egg: PackedScene

func _ready():
	_add_to_group(self)

func start_hover():
	pass
	
func exit_hover():
	pass
	
func clicked():
	if Manager.holding_egg: return
	
	#var clone: Interactable = egg.instantiate()
	#get_tree().current_scene.add_child(clone)
	
	#Manager.egg_scene = clone
	Manager.set_egg(egg)
	#clone.call("spawn_egg")
