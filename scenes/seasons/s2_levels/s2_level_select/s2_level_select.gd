extends Control

const SEASON = 2

func _ready():
	SaveData.load_game()
	var unlocked = SaveData.unlocked_levels.get(SEASON, 1)

	for i in range(1, 11):
		var button_path = "GridContainer/LevelButton%d" % i
		var button = get_node(button_path)
		button.disabled = i > unlocked
		button.pressed.connect(func(): _on_level_pressed(i))

func _on_level_pressed(level_number: int):
	var path = "res://scenes/seasons/s%d_levels/S%dLevel%d.tscn" % [SEASON, SEASON, level_number]
	get_tree().change_scene_to_file(path)

func _on_BackButton_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/season_select/SeasonSelect.tscn")
