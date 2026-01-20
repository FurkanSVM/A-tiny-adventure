extends Node2D

@onready var info_popup: Popup = $Sprite2D/Popup
@onready var main_menu_theme: AudioStreamPlayer2D = $Sprite2D/main_menu_theme

func _ready() -> void:
	Music.stop()
	main_menu_theme.play(2.0)
	

func _on_start_button_pressed() -> void:
	main_menu_theme.stop()
	Music.play()
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	

func _on_exit_button_pressed() -> void:
	get_tree().quit()
