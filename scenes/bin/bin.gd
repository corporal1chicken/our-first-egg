extends Interactable

func _ready() -> void:
	_add_to_group(self)

	Signals.start_hold_egg.connect(_on_start_hold)
	Signals.end_hold_egg.connect(_on_end_hold)
	
func start_hover():
	pass
	
func exit_hover():
	pass
	
func clicked():
	if not Manager.holding_egg: return
	
	var value = Manager.egg.get_sell_value()
	
	Manager.change_money("add", value * 0.5)
	Manager.end_hold_egg()
	
func _on_start_hold():
	pass
	
func _on_end_hold():
	pass
