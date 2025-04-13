extends CharacterBody2D

@export var gravity: float = 980.0
@onready var goal_area: Area2D = $GoalArea

func _ready():
	goal_area.body_entered.connect(_on_goal_area_body_entered)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	move_and_slide()

func _on_goal_area_body_entered(body: Node):
	if body.is_in_group("player"):
		print("🎉 Level Completed!")
		if body.has_method("on_reach_goal"):
			body.on_reach_goal()
