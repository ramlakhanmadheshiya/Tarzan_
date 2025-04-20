extends CanvasLayer

func update_spear(count: int):
	$UIRoot/MainUI/spear/SpearCount.text = str(count)

func update_fruit(fruit: int, golden: int):
	$UIRoot/MainUI/Fruit/FruitCount.text = str(fruit)
	$UIRoot/MainUI/GoldenFruit/GoldenFruitCount.text = str(golden)

@onready var pause_menu_scene = preload("res://scenes/pause_menu/PauseMenu.tscn") # Adjust path if needed

func _on_pause_button_pressed() -> void:
	if get_tree().paused:
		return # prevent double pause

	var pause_menu = pause_menu_scene.instantiate()
	get_tree().current_scene.add_child(pause_menu)
	get_tree().paused = true
