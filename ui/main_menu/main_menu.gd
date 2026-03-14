extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var current_screen: ColorRect

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
			
			if not Manager.game_started:
				Manager.start_game()
			else:
				Signals.resume_game.emit()
		"about":
			$ColorRect/VBoxContainer.visible = false
			$ColorRect/back.visible = true
			$ColorRect/about_screen.visible = true
			
			current_screen = $ColorRect/about_screen
		"info":
			$ColorRect/VBoxContainer.visible = false
			$ColorRect/back.visible = true
			$ColorRect/info_screen.visible = true
			
			current_screen = $ColorRect/info_screen
		"how_to":
			$ColorRect/how_to_screen.visible = true
			$ColorRect/back.visible = true
			$ColorRect/VBoxContainer.visible = false
			
			current_screen = $ColorRect/how_to_screen
		"quit":
			get_tree().quit()

	button.release_focus()

func _on_link_pressed(button: Button):
	OS.shell_open(links[button.name])
	button.release_focus()
	
func show_menu():
	Manager.on_menu = true
	self.visible = true
	Signals.pause_game.emit()
	
	animation_player.play_backwards("play")
	
func hide_menu():
	Manager.on_menu = false
	animation_player.play("play")
	await animation_player.animation_finished
	
	self.visible = false

func _enable_buttons():
	for button in $ColorRect/VBoxContainer.get_children():
		if button.name == "info": continue
		
		button.disabled = false

func _on_back_pressed():
	current_screen.visible = false
	$ColorRect/VBoxContainer.visible = true
	$ColorRect/back.visible = false
