extends Node

var template: Interactable
var crates: Node3D

# Test Amount: 1178
var player_money: float = 72.0
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
	if upgrades_bought == 5 and player_money >= 150.0:
		Signals.ending_reached.emit()

func get_file_contents(file_path: String) -> Dictionary:
	var json_text = FileAccess.get_file_as_string(file_path)
	var json_dictionary = JSON.parse_string(json_text)
	
	return json_dictionary
