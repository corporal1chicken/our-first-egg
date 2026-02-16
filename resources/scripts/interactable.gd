extends Node3D
class_name Interactable

@export var hover_text = ""
@export var block_hover: bool = false
@export var block_click: bool = false

func _add_to_group(object):
	object.add_to_group("interactables")
