extends Node3D

@export_category("Pallet")
@export var egg: PackedScene
@export var temp: StaticBody3D

@onready var eggs: Node3D = $eggs

func _ready():
	Signals.game_started.connect(_set_pallet)
	
func _set_pallet():
	for visual in eggs.get_children():
		visual.visible = false
		visual.block_hover = true
		visual.block_click = true
	
	var order: Array = Manager.get_orders()
		
	order.shuffle()
	
	for i in range(order.size()):
		var marker = str(i + 1)
		var found_egg = eggs.get_node(marker)
		var colour = order[i]
		
		found_egg.block_hover = false
		found_egg.block_click = false
		found_egg.visible = true
		found_egg.name = colour
		found_egg.call("setup", colour)
	
	"""
	var orders: Array = Manager.get_orders()
	
	var flat: Array = []
	
	for array in orders:
		flat.append_array(array)
		
	flat.shuffle()
	
	for i in range(flat.size()):
		var clone = temp.duplicate()
		add_child(clone)
		
		var new_position = positions.get_node(str(i + 1)).global_position
		clone.global_position = new_position
	"""
