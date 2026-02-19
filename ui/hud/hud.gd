extends Control

@export var main_menu: Control

@onready var interaction_label: RichTextLabel = $interaction_label
@onready var upgrades_holder: VBoxContainer = $upgrades

var upgrades = {
	value = {
		key = "value",
		cost = 24.0
	},
	storage = {
		key = "storage",
		cost = 35.0
	},
	special = {
		key = "special",
		cost = 50.0
	},
	autosell = {
		key = "autosell",
		cost = 70.0
	}
}

func _ready():
	Signals.hover_started.connect(_on_hover_started)
	Signals.hover_ended.connect(_on_hover_ended)
	Signals.update_ui.connect(_on_update_ui)
	Signals.menu_opened.connect(_on_menu_opened)
	Signals.menu_closed.connect(_on_menu_closed)
	Signals.start_hold_egg.connect(_on_holding_egg)
	Signals.end_hold_egg.connect(_on_cancel_egg)
	
	for upgrade in upgrades_holder.get_children():
		upgrade.pressed.connect(_on_upgrade_pressed.bind(upgrade))
	
func _on_hover_started(hover_text):
	interaction_label.text = hover_text
	interaction_label.visible = true
	
func _on_hover_ended():
	interaction_label.visible = false

func _on_update_ui():
	$money.text = "£%s0" % str(Manager.player_money)

func _on_menu_opened():
	$AnimationPlayer.play_backwards("enter")
	await $AnimationPlayer.animation_finished
	self.visible = true
	
func _on_menu_closed():
	$AnimationPlayer.play("enter")

func _on_holding_egg():
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
