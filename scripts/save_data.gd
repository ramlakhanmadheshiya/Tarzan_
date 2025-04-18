extends Node

const SAVE_PATH = "user://save_game.save"

var unlocked_season: int = 1
var unlocked_levels := {1: 1, 2: 0, 3: 0}  # Season → Highest unlocked level

func save_game():
	var save_dict = {
		"unlocked_season": unlocked_season,
		"unlocked_levels": unlocked_levels
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_dict))
	file.close()

func load_game():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		if data:
			unlocked_season = data["unlocked_season"]
			unlocked_levels = data["unlocked_levels"]
