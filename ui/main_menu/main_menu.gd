extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var links: Dictionary = {
	notion = "https://corporalchicken.notion.site/Our-First-Egg-308a5d2ada1580b780b7dc8305b3e9f7?source=copy_link",
	youtube = "https://www.youtube.com/playlist?list=PLWUHEaMTtDoHS7ipke7ca7oxRGoZvP9HI"
}

func _ready():
	animation_player.play("intro")
	
	for button in $ColorRect/VBoxContainer.get_children():
		button.pressed.connect(_on_option_pressed.bind(button))

	for button in $ColorRect/about_screen/links.get_children():
		button.pressed.connect(_on_link_pressed.bind(button))

func _on_option_pressed(button: Button):
	match button.name:
		"play":
			hide_menu()
		"about":
			$ColorRect/VBoxContainer.visible = false
			$ColorRect/about_screen.visible = true
		"info":
			$ColorRect/VBoxContainer.visible = false
			$ColorRect/info_screen.visible = true
		"quit":
			get_tree().quit()

	button.release_focus()

func _on_back_pressed() -> void:
	$ColorRect/VBoxContainer.visible = true
	$ColorRect/about_screen.visible = false
	
func _on_info_back_pressed():
	$ColorRect/VBoxContainer.visible = true
	$ColorRect/info_screen.visible = false
	
func _on_link_pressed(button: Button):
	OS.shell_open(links[button.name])
	button.release_focus()
	
func show_menu():
	Manager.on_menu = true
	self.visible = true
	Signals.menu_opened.emit()
	
	animation_player.play_backwards("play")
	
func hide_menu():	
	Manager.on_menu = false
	animation_player.play("play")
	await animation_player.animation_finished
	
	self.visible = false
	Signals.menu_closed.emit()
