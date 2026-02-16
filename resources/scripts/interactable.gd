extends Node3D
class_name Interactable

@export_category("Interactable")
@export var hover_text = ""

func _add_to_group(object):
	object.add_to_group("interactables")
