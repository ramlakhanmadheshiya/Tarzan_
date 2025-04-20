extends CanvasLayer

func _on_resume_button_pressed():
	get_tree().paused = false
	self.visible = false

func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
