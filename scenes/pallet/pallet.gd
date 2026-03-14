extends Node3D

@export_category("Pallet")
@export var egg: PackedScene
@export var temp: StaticBody3D

@onready var eggs: Node3D = $eggs

var file_path: String = "res://resources/data/egg_types.json"
var pool: Dictionary

func _ready():
	Signals.start_round.connect(_set_pallet)
	Signals.game_started.connect(_set_pallet)
	
	pool = Manager.get_file_contents(file_path)
	
func _get_random_egg():
	var total_weight = 0
	
	for key in pool.keys(): 
		total_weight += pool[key].chance
	
	var roll = randi_range(1, total_weight)
	
	var c = 0
	for egg in pool:
		c += pool[egg].chance
		
		if roll <= c:
			return egg
			
	return "red"
	
func _set_pallet():
	print("starting round")
	
	var count = 1
	
	for visual in eggs.get_children():
		visual.visible = false
		visual.block_hover = true
		visual.block_click = true
		visual.name = str(count)
		count += 1
	
	var order: Array = Manager.get_orders()
		
	for i in randi_range(2, 4):
		order.append(_get_random_egg())
	
	order.shuffle()
	
	Manager.total_eggs = order.size()
	
	for i in range(order.size()):
		var marker = str(i + 1)
		var found_egg = eggs.get_node(marker)
		var colour = order[i]
		
		found_egg.block_hover = false
		found_egg.block_click = false
		found_egg.visible = true
		found_egg.name = colour
		found_egg.call("setup", colour)
