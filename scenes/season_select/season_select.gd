extends Control

func _ready():
	SaveData.load_game()
	$HBoxContainer/Season1Button.grab_focus()
	# Unlock logic
	$HBoxContainer/Season1Button.disabled = false
	$HBoxContainer/Season2Button.disabled = SaveData.unlocked_season < 2
	#$HBoxContainer/Season2Button.disabled = false
	$HBoxContainer/Season3Button.disabled = SaveData.unlocked_season < 3
	#$HBoxContainer/Season3Button.disabled = false

func _on_Season1Button_pressed():
	get_tree().change_scene_to_file("res://scenes/seasons/s1_levels/s1_level_select/S1LevelSelect.tscn")

func _on_Season2Button_pressed():
	get_tree().change_scene_to_file("res://scenes/seasons/s2_levels/s2_level_select/S2LevelSelect.tscn")

func _on_Season3Button_pressed():
	get_tree().change_scene_to_file("res://scenes/seasons/s3_levels/s3_level_select/S3LevelSelect.tscn")

func _on_BackButton_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")
