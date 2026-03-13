extends Node

var template: Interactable
var crates: Node3D

var player_money: float = 0.0
var on_menu: bool = true
var holding_egg: bool = false

var egg: Interactable

var special_unlocked: bool = false

var upgrades_bought: int = 0
var total_eggs: int = 0

var game_started: bool = false

func change_money(action: String, amount: float):
	match action:
		"add": player_money += amount
		"remove": player_money -= amount
		
	Signals.update_ui.emit()
	check_if_finished()

func start_hold_egg(held_egg):
	egg = held_egg
	holding_egg = true
	Signals.start_hold_egg.emit()
	
func cancel_hold_egg():
	egg = null
	holding_egg = false
	Signals.end_hold_egg.emit()
	
func end_hold_egg():
	egg.visible = false
	egg.block_click = true
	egg.block_hover = true
	egg = null
	
	total_eggs -= 1
	
	holding_egg = false
	Signals.end_hold_egg.emit()

func sell_all():
	for child in crates.get_children():
		child.selling()
		
func get_orders() -> Array:
	var orders = []
	
	for child in crates.get_children():
		orders.append_array(child.current_order)
	
	total_eggs = orders.size()
	
	return orders
	
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

func start_game():
	game_started = true
	Signals.game_started.emit()
