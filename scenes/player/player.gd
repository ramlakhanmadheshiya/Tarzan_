extends CharacterBody2D

@export var speed = 400.0
@export var jump_velocity = -450.0
@export var swim_speed_horizontal = 100.0
@export var swim_speed_vertical = 80.0
@export var water_gravity_scale = 0.3
@export var attack_duration = 0.6
@export var deceleration_factor = 5.0
@export var spear_scene: PackedScene

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D
@onready var water_detector = $WaterDetector

enum State { IDLE_RUN, GO_UP, GO_DOWN, SWIM, ATTACK, DIE, GOAL }
var current_state = State.IDLE_RUN
var facing_direction = 1
var is_in_water = false
var is_attacking = false
var attack_timer = 0.0
var fruit_score: int = 0
var reached_goal = false

func _ready():
	add_to_group("player")
	update_animation()

func _physics_process(delta):
	if current_state == State.DIE or current_state == State.GOAL:
		return

	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false

	if not is_on_floor() and not is_in_water:
		velocity.y += gravity * delta
	elif is_in_water:
		velocity.y += gravity * water_gravity_scale * delta

	if not is_attacking:
		handle_input(delta)

	move_and_slide()
	update_state()
	update_animation()

func handle_input(delta):
	# Autorun always to the right
	velocity.x = speed
	facing_direction = 1

	var vertical_direction = 0
	if Input.is_action_pressed("go_up"):
		vertical_direction = -1
	elif Input.is_action_pressed("go_down"):
		vertical_direction = 1

	if is_in_water:
		velocity.x = speed
		if vertical_direction:
			velocity.y = vertical_direction * swim_speed_vertical
		else:
			velocity.y = move_toward(velocity.y, 0, swim_speed_vertical * deceleration_factor * delta)
	else:
		if Input.is_action_just_pressed("go_up") and is_on_floor():
			velocity.y = jump_velocity

	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		attack_timer = attack_duration
		velocity.x = 0  # Stop during attack

		if spear_scene:
			var spear = spear_scene.instantiate()
			spear.position = global_position
			spear.direction = facing_direction
			get_tree().current_scene.add_child(spear)

	animated_sprite.flip_h = false  # Always facing right

func update_state():
	if current_state == State.DIE or current_state == State.GOAL:
		return
	if is_attacking:
		current_state = State.ATTACK
		return

	if is_in_water:
		current_state = State.SWIM
	else:
		if Input.is_action_pressed("go_up"):
			current_state = State.GO_UP
		elif Input.is_action_pressed("go_down"):
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
	print("🍇 Fruit score: ", fruit_score)

# ✅ Called by goal.gd when player reaches the goal
func on_reach_goal():
	if not reached_goal:
		reached_goal = true
		current_state = State.GOAL
		velocity = Vector2.ZERO
		update_animation()

		await get_tree().create_timer(2.0).timeout
		get_tree().reload_current_scene()
