extends Node3D

@onready var camera_3d: Camera3D = $"../Camera3D"

var current_hover = null

func _process(_delta: float):
	if Manager.is_on_menu: return
	
	var mouse_position = get_viewport().get_mouse_position()
	
	var from = camera_3d.project_ray_origin(mouse_position)
	var to = from + camera_3d.project_ray_normal(mouse_position) * 1000
	
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space.intersect_ray(query)
	
	var hit: Interactable = null
	
	if result:
		hit = result.collider
		
		if hit and not hit is Interactable:
			hit = null
			
	if current_hover != hit:
		if current_hover:
			current_hover.call("exit_hover")
			Signals.hover_ended.emit()
		
		current_hover = hit
		
		if current_hover:
			if current_hover.block_hover: return
			
			current_hover.call("start_hover")
			Signals.hover_started.emit(hit.hover_text)

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if current_hover:
			if current_hover.block_click: return
			
			current_hover.call("clicked")
