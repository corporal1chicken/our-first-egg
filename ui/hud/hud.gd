extends Control

@export var main_menu: Control

@onready var interaction_label: RichTextLabel = $interaction_label
@onready var upgrades_holder: VBoxContainer = $upgrades

var upgrades = {
	value = {
		key = "value",
		cost = 5.0
	},
	bonus = {
		key = "bonus",
		cost = 8.0
	},
	shield = {
		key = "shield",
		cost = 12.0
	},
	overflow = {
		key = "overflow",
		cost = 15.0
	},
	bin = {
		key = "bin",
		cost = 18.0
	}
}

func _ready():
	Signals.hover_started.connect(_on_hover_started)
	Signals.hover_ended.connect(_on_hover_ended)
	Signals.update_ui.connect(_on_update_ui)
	Signals.pause_game.connect(_on_menu_opened)
	Signals.resume_game.connect(_on_menu_closed)
	Signals.start_hold_egg.connect(_on_holding_egg)
	Signals.end_hold_egg.connect(_on_cancel_egg)
	Signals.debug_signal.connect(_on_debug_signal)
	Signals.start_round.connect(_on_start_round)
	Signals.game_started.connect(_on_game_started)
	
	for upgrade in upgrades_holder.get_children():
		upgrade.pressed.connect(_on_upgrade_pressed.bind(upgrade))
	
func _on_hover_started(hover_text):
	interaction_label.text = hover_text
	interaction_label.visible = true
	
func _on_hover_ended():
	interaction_label.visible = false

func _on_update_ui():
	$money.text = "£%.2f" % Manager.player_money

func _on_menu_opened():
	if not Manager.game_started: return
	
	$AnimationPlayer.play_backwards("enter")
	await $AnimationPlayer.animation_finished
	self.visible = true
	
func _on_menu_closed():
	if not Manager.game_started: return
	$AnimationPlayer.play("enter")

func _on_holding_egg():
	$egg_status.text = "Holding %s Egg" % Manager.egg.name.capitalize()
	$egg_status.visible = true
	
func _on_cancel_egg():
	$egg_status.visible = false

func _on_sell_all_pressed() -> void:
	Manager.sell_all()
	
func _on_upgrade_pressed(button: Button):
	button.release_focus()
	var success: bool = Manager.pass_upgrade(upgrades[button.name])
	
	if success:
		button.disabled = true
		
		var cost_label = button.get_node_or_null("cost")
		cost_label.visible = false

func _on_menu_pressed():
	main_menu.show_menu()

func _on_info_mouse_entered() -> void:
	$info/instructions.visible = true

func _on_info_mouse_exited() -> void:
	$info/instructions.visible = false

func _on_debug_signal(new_text):
	$debug.text = new_text

func _on_start_round():
	$round_end/label.text = "Creating Order\nRound: %d/5" % Manager.rounds_played
	$AnimationPlayer.play("round_end")

func _on_game_started():
	$round_end/label.text = "Creating Order\nRound: %d/5" % Manager.rounds_played
	$AnimationPlayer.play("round_end")
	await $AnimationPlayer.animation_finished	
	
	$AnimationPlayer.play("enter")
