extends Node

var template: Interactable
var crates: Node3D

var player_money: float = 0.0
var on_menu: bool = true
var holding_egg: bool = false

var egg: Interactable

var special_unlocked: bool = false

var upgrades_bought: int = 0

func change_money(action: String, amount: float):
	match action:
		"add": player_money += amount
		"remove": player_money -= amount
		
	Signals.update_ui.emit()
	check_if_finished()
		
func create_egg():
	if egg != null: return
	
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

func pass_upgrade(upgrade_info: Dictionary):
	if player_money < upgrade_info.cost:
		return false
		
	change_money("remove", upgrade_info.cost)
	
	if upgrade_info.key == "special":
		special_unlocked = true
	else:
		Signals.upgrade_bought.emit(upgrade_info.key)
	
	upgrades_bought += 1
	
	check_if_finished()
	
	return true

func check_if_finished():
	if upgrades_bought == 4 and player_money >= 150.0:
		Signals.ending_reached.emit()
