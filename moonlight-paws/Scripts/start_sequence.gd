extends Node2D
@onready var levelstart_1: Sprite2D = $Levelstart1
@onready var levelstart_2: Sprite2D = $Levelstart2
@onready var levelstart_3: Sprite2D = $Levelstart3
@onready var level_ui: TextureRect = $"../LevelUI"
@onready var player: CharacterBody2D = $"../Player"
@onready var start_anim: AnimationPlayer = $start_anim


var intro_steps = []
var current_step_index: int = 0
var skipping: bool = false
var step_timer: Timer = null

func _ready() -> void:
	# Hide everything initially
	levelstart_1.visible = false
	levelstart_2.visible = false
	levelstart_3.visible = false
	level_ui.visible = false
	player.visible = false

	# Define steps: node, fade-in, fade-out, duration
	intro_steps = [
		{"node": levelstart_1, "fade_in": "start1_FadeIn", "fade_out": "start1_FadeOut", "duration": 10.0},
		{"node": levelstart_2, "fade_in": "start2_FadeIn", "fade_out": "start2_FadeOut", "duration": 10.0},
		{"node": levelstart_3, "fade_in": "start3_FadeIn", "fade_out": "start3_FadeOut", "duration": 10.0},
	]

	# Timer for auto-advance
	step_timer = Timer.new()
	add_child(step_timer)
	step_timer.one_shot = true
	step_timer.connect("timeout", Callable(self, "_on_step_timer_timeout"))

	# Start the first step
	play_step(0)

func play_step(index: int) -> void:
	if index >= intro_steps.size():
		end_intro()
		return

	current_step_index = index
	skipping = false
	var step = intro_steps[index]
	step["node"].visible = true
	start_anim.play(step["fade_in"])

func _input(event):
	if event.is_action_pressed("click"):
		skip_current_step()

func skip_current_step() -> void:
	if skipping:
		return
	skipping = true

	var step = intro_steps[current_step_index]
	# Stop timer if waiting
	if step_timer.is_stopped() == false:
		step_timer.stop()

	# Play fade-out animation immediately
	start_anim.play(step["fade_out"])


func _on_step_timer_timeout() -> void:
	# Timer finished: auto skip to fade-out
	skip_current_step()

func end_intro() -> void:
	# Show menu
	level_ui.visible = true
	player.visible = true
	player.canMove = true

func _on_start_anim_animation_finished(anim_name: StringName) -> void:
	var step = intro_steps[current_step_index]

	if anim_name == step["fade_in"] and not skipping:
		# Start timer to auto-advance after duration
		step_timer.start(step["duration"])
	elif anim_name == step["fade_out"]:
		# Fade-out finished: hide node and go to next step
		step["node"].visible = false
		play_step(current_step_index + 1)
