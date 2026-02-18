extends Node

var template: Interactable
var crates: Node3D

var player_money: float = 0.0
var on_menu: bool = true
var holding_egg: bool = false

var egg: Interactable

func change_money(action: String, amount: float):
	match action:
		"add": player_money += amount
		"remove": player_money -= amount
		
	Signals.update_ui.emit()
		
func create_egg():
	var clone = template.duplicate()
	get_tree().current_scene.add_child(clone)
	
	egg = clone
	
	await get_tree().process_frame
	
	clone.call("setup")

func start_hold_egg():
	holding_egg = true
	Signals.start_hold_egg.emit()
	
func cancel_hold_egg():
	holding_egg = false
	Signals.end_hold_egg.emit()
	
func end_hold_egg():
	egg.queue_free()
	egg = null
	
	holding_egg = false
	Signals.end_hold_egg.emit()

func sell_all():
	for child in crates.get_children():
		child.selling()

"""
var is_on_menu: bool = true

var holding_egg: bool = false

var player_money: float = 0.0
	
func set_holding_egg():
	holding_egg = true
	Signals.is_holding_egg.emit()
	
func cancel_egg():
	holding_egg = false
	
	Signals.finished_holding_egg.emit()

func clear_egg():
	holding_egg = false
	
	Signals.finished_holding_egg.emit()

func add_money(amount: float):
	player_money += amount
	Signals.update_ui.emit()
"""
