extends Node

var is_on_menu: bool = true

var holding_egg: bool = false
var egg_scene: Interactable

var player_money: float = 0.0

func set_egg(egg: PackedScene):
	var clone: Interactable = egg.instantiate()
	get_tree().current_scene.add_child(clone)
	
	egg_scene = clone
	clone.call("spawn_egg")
	
func set_holding_egg():
	holding_egg = true
	Signals.is_holding_egg.emit()
	
func cancel_egg():
	holding_egg = false
	
	Signals.finished_holding_egg.emit()

func clear_egg():
	egg_scene.queue_free()
	egg_scene = null
	holding_egg = false
	
	Signals.finished_holding_egg.emit()

func add_money(amount: float):
	player_money += amount
	Signals.update_ui.emit()
