extends Node

const SAVE_PATH = "user://save_game.save"

var unlocked_season: int = 1
var unlocked_levels := {1: 1, 2: 0, 3: 0}

# ✅ Add these lines:
var fruit_score := 0
var golden_score := 0
var spear_count := 3

func save_game():
	var save_dict = {
		"unlocked_season": unlocked_season,
		"unlocked_levels": unlocked_levels,
		"fruit_score": fruit_score,
		"golden_score": golden_score,
		"spear_count": spear_count
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
			fruit_score = data.get("fruit_score", 0)
			golden_score = data.get("golden_score", 0)
			spear_count = data.get("spear_count", 3)
