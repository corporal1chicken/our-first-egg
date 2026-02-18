extends Node3D

var template: Interactable
var egg: Interactable

func duplicate_egg():
	if Manager.holding_egg: return
		
	var clone = template.duplicate()
	get_tree().current_scene.add_child(clone)
	
	egg = clone
	
	clone.call("setup")
