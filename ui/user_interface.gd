extends Control

@onready var interaction_label: RichTextLabel = $CanvasLayer/interaction_label

func _ready():
	Signals.hover_started.connect(_on_hover_started)
	Signals.hover_ended.connect(_on_hover_ended)
	Signals.update_ui.connect(_on_update_ui)
	Signals.menu_opened.connect(_on_menu_opened)
	Signals.menu_closed.connect(_on_menu_closed)
	
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
	
func _on_menu_closed():
	$CanvasLayer/menu.visible = true
	$CanvasLayer/money.visible = true

func _on_button_pressed():
	$CanvasLayer/main_menu.show_menu()
