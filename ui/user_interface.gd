extends Control

@onready var interaction_label: RichTextLabel = $CanvasLayer/interaction_label

func _ready():
	Signals.hover_started.connect(_on_hover_started)
	Signals.hover_ended.connect(_on_hover_ended)
	Signals.update_ui.connect(_on_update_ui)
	Signals.menu_opened.connect(_on_menu_opened)
	Signals.menu_closed.connect(_on_menu_closed)
	Signals.start_hold_egg.connect(_on_holding_egg)
	Signals.end_hold_egg.connect(_on_cancel_egg)
	
func _on_hover_started(hover_text):
	interaction_label.text = hover_text
	interaction_label.visible = true
	
func _on_hover_ended():
	interaction_label.visible = false

func _on_update_ui():
	$CanvasLayer/money.text = "£%s0" % str(Manager.player_money)

func _on_menu_opened():
	$CanvasLayer/menu.visible = false
	$CanvasLayer/money.visible = false
	$CanvasLayer/sell_all.visible = false
	
func _on_menu_closed():
	$CanvasLayer/menu.visible = true
	$CanvasLayer/money.visible = true
	$CanvasLayer/sell_all.visible = true

func _on_button_pressed():
	$CanvasLayer/main_menu.show_menu()

func _on_holding_egg():
	$CanvasLayer/egg_status.visible = true
	
func _on_cancel_egg():
	$CanvasLayer/egg_status.visible = false

func _on_sell_all_pressed() -> void:
	Manager.sell_all()
