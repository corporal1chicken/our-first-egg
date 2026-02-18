extends Node3D

func _ready() -> void:
	Manager.template = $template
	Manager.crates = $build/crates
