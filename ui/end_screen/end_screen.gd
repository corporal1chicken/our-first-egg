extends Control

func _ready():
	Signals.ending_reached.connect(_play_ending)

func _play_ending():
	self.visible = true
	self.mouse_filter = Control.MOUSE_FILTER_STOP
	$AnimationPlayer.play("end")


func _on_button_pressed() -> void:
	get_tree().quit()
