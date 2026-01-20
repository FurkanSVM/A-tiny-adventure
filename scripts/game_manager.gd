extends Node

var coins = 0

@onready var score_label: Label = $ScoreLabel

	

func add_point():
	coins+=1
	score_label.text = "Collected coins : " + str(coins)
	

	


func _on_flying_demon_game_over() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
