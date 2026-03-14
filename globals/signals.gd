extends Node

signal hover_started(hover_text)
signal hover_ended()

signal update_ui()
signal pause_game()
signal resume_game()
signal game_started()

signal start_round()

signal start_hold_egg()
signal end_hold_egg()

signal upgrade_bought(key: String)

signal ending_reached()

signal debug_signal(text)
