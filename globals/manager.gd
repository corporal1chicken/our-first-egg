extends Node

var holding_egg: bool = false
var egg_scene: Interactable

func set_holding_egg():
	holding_egg = true
	
	Signals.is_holding_egg.emit()
