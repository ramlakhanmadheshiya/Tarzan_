extends CanvasLayer

func update_spear(count: int):
	$UIRoot/MainUI/spear/SpearCount.text = str(count)

func update_fruit(fruit: int, golden: int):
	$UIRoot/MainUI/Fruit/FruitCount.text = str(fruit)
	$UIRoot/MainUI/GoldenFruit/GoldenFruitCount.text = str(golden)

func _on_PauseButton_pressed():
	get_tree().paused = not get_tree().paused
