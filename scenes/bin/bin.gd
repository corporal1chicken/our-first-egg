extends Interactable

var sell_penalty = 0.5

func _ready() -> void:
	_add_to_group(self)

	Signals.upgrade_bought.connect(_on_upgrade_bought)
	
func start_hover():
	pass
	
func exit_hover():
	pass
	
func clicked():
	if not Manager.holding_egg: return
	
	var value = Manager.egg.get_sell_value()
	
	Manager.change_money("add", value * sell_penalty)
	Manager.end_hold_egg()
	
func _on_upgrade_bought(key: String):
	if key == "bin":
		sell_penalty = 1.0
		$sell.text = "1.0x"
