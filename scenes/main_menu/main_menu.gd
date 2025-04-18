extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/StartButton.grab_focus()

func _on_start_button_pressed() -> void:
	SaveData.load_game()
	var season = SaveData.unlocked_season
	var level = SaveData.unlocked_levels.get(season, 1)
	var level_path = "res://scenes/seasons/s%d_levels/S%dLevel%d.tscn" % [season, season, level]
	get_tree().change_scene_to_file(level_path)

func _on_option_button_pressed() -> void:
	pass # Replace with function body.

func _on_choose_level_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/season_select/SeasonSelect.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
