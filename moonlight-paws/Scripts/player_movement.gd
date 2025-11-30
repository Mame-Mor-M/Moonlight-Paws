extends CharacterBody2D

@export var speed = 400
@export var startingPos: Vector2
@export var canMove: bool = false

var target = position


func _ready() -> void:
	target = startingPos

func _physics_process(delta):
	velocity = position.direction_to(target) * speed
	# look_at(target)
	if position.distance_to(target) > 10:
		move_and_slide()


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed(&"click") and canMove:
		target = get_global_mouse_position()
		print(name)
