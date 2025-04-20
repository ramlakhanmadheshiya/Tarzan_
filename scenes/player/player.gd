extends CharacterBody2D

@export var speed = 200.0
@export var jump_velocity = -450.0
@export var swim_speed_horizontal = 100.0
@export var water_gravity_scale = 0.3
@export var attack_duration = 0.6
@export var spear_scene: PackedScene

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D
@onready var water_detector = $WaterDetector
#@onready var floor_ray = $FloorRay

enum State { IDLE_RUN, GO_UP, GO_DOWN, SWIM, ATTACK, DIE, GOAL }
var current_state = State.IDLE_RUN

var facing_direction = 1
var is_in_water = false
var is_attacking = false
var attack_timer = 0.0
var go_up_timer = 0.0
var go_down_timer = 0.0
var fruit_score = 0
var golden_score = 0
var spear_count = 3
var reached_goal = false

func _ready():
	add_to_group("player")
	SaveData.load_game()
	fruit_score = SaveData.fruit_score
	golden_score = SaveData.golden_score
	spear_count = SaveData.spear_count
	update_animation()
	update_ui()

func _physics_process(delta):
	if current_state in [State.DIE, State.GOAL]:
		return

	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false

	if go_up_timer > 0:
		go_up_timer -= delta

	if go_down_timer > 0:
		go_down_timer -= delta

	if not is_on_floor() and not is_in_water:
		velocity.y += gravity * delta
	elif is_in_water:
		velocity.y = 0

	if Input.is_action_just_pressed("go_up") and is_on_floor():
		velocity.y = jump_velocity
		go_up_timer = 0.5

	if Input.is_action_just_pressed("go_down") and is_on_floor():
		position.y += 1
		go_down_timer = 0.2

	handle_input(delta)
	move_and_slide()
	update_state()
	update_animation()

func handle_input(delta):
	if is_in_water:
		velocity.x = swim_speed_horizontal
		velocity.y = 0
		return

	velocity.x = speed
	facing_direction = 1

	if Input.is_action_just_pressed("attack") and not is_attacking and spear_count > 0:
		is_attacking = true
		attack_timer = attack_duration
		velocity.x = 0
		spear_count -= 1
		SaveData.spear_count = spear_count
		SaveData.save_game()
		update_ui()

		if spear_scene:
			var spear = spear_scene.instantiate()
			spear.position = global_position
			spear.direction = facing_direction
			get_tree().current_scene.add_child(spear)

	animated_sprite.flip_h = false

func update_state():
	if current_state in [State.DIE, State.GOAL]:
		return
	if is_attacking:
		current_state = State.ATTACK
	elif is_in_water:
		current_state = State.SWIM
	elif go_up_timer > 0:
		current_state = State.GO_UP
	elif go_down_timer > 0:
		current_state = State.GO_DOWN
	else:
		current_state = State.IDLE_RUN

func update_animation():
	var anim_name = "idle_run"
	match current_state:
		State.IDLE_RUN: anim_name = "idle_run"
		State.GO_UP: anim_name = "go_up"
		State.GO_DOWN: anim_name = "go_down"
		State.SWIM: anim_name = "swim"
		State.ATTACK: anim_name = "attack"
		State.DIE: anim_name = "die"
		State.GOAL: anim_name = "goal"
	if animated_sprite.animation != anim_name:
		animated_sprite.play(anim_name)

func update_ui():
	var ui = get_tree().current_scene.get_node_or_null("PlayerUI")
	if ui:
		ui.update_spear(spear_count)
		ui.update_fruit(fruit_score, golden_score)

func set_in_water(status: bool):
	is_in_water = status
	if is_in_water:
		velocity.y = 0

func die(instant := false):
	if current_state == State.DIE:
		return
	is_attacking = false
	velocity = Vector2.ZERO
	if instant:
		current_state = State.DIE
		update_animation()
	else:
		await get_tree().create_timer(0.5).timeout
		current_state = State.DIE
		update_animation()
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()

func collect_fruit():
	fruit_score += 1
	SaveData.fruit_score = fruit_score
	SaveData.save_game()
	update_ui()

func collect_golden_fruit():
	golden_score += 1
	SaveData.golden_score = golden_score
	SaveData.save_game()
	update_ui()

func collect_spear():
	spear_count += 1
	SaveData.spear_count = spear_count
	SaveData.save_game()
	update_ui()

func on_reach_goal():
	if not reached_goal:
		reached_goal = true
		current_state = State.GOAL
		velocity = Vector2.ZERO
		update_animation()

		var filename = get_tree().current_scene.scene_file_path.get_file()
		var s_index = filename.find("S")
		var level_index = filename.find("Level")

		if s_index == -1 or level_index == -1:
			push_error("❌ Invalid scene name format! Expected format like 'S1Level3.tscn'")
			return

		var season = int(filename.substr(s_index + 1, level_index - s_index - 1))
		var level = int(filename.substr(level_index + 5, filename.length() - level_index - 10))  # "Level" is 5 chars

		var current_unlocked = SaveData.unlocked_levels.get(season, 0)
		if level >= current_unlocked:
			SaveData.unlocked_levels[season] = level + 1
			if level == 10:
				SaveData.unlocked_season = max(SaveData.unlocked_season, season + 1)
				SaveData.unlocked_levels[season + 1] = 1

		print("✅ Reached goal: Season %d, Level %d" % [season, level])
		SaveData.save_game()

		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")

	if not reached_goal:
		reached_goal = true
		current_state = State.GOAL
		velocity = Vector2.ZERO
		update_animation()

		var path = get_tree().current_scene.scene_file_path
		var season = int(path.get_file().split("_")[0].replace("S", ""))
		var level = int(path.get_file().split("_")[1].replace("Level", "").replace(".tscn", ""))
		
		var current_unlocked = SaveData.unlocked_levels.get(season, 0)
		if level >= current_unlocked:
			SaveData.unlocked_levels[season] = level + 1
			if level == 10:
				SaveData.unlocked_season = max(SaveData.unlocked_season, season + 1)
				SaveData.unlocked_levels[season + 1] = 1

		print("✅ Saving after reaching goal...")
		SaveData.save_game()

		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")
