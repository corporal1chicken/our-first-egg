extends Node

var holding_egg: bool = false
var egg_scene: Interactable

func set_egg(egg: PackedScene):
	var clone: Interactable = egg.instantiate()
	get_tree().current_scene.add_child(clone)
	
	egg_scene = clone
	clone.call("spawn_egg")
	
func set_holding_egg():
	holding_egg = true
	Signals.is_holding_egg.emit()

func clear_egg():
	egg_scene.queue_free()
	egg_scene = null
	holding_egg = false
	
	Signals.finished_holding_egg.emit()
