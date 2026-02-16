extends Control

@onready var interaction_label: RichTextLabel = $CanvasLayer/interaction_label

func _ready():
	Signals.hover_started.connect(_on_hover_started)
	Signals.hover_ended.connect(_on_hover_ended)
	
func _on_hover_started(hover_text):
	interaction_label.text = hover_text
	interaction_label.visible = true
	
func _on_hover_ended():
	interaction_label.visible = false
