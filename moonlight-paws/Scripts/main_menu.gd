extends Node2D

@onready var play_button: TextureButton = $PlayButton
@onready var quit_button: TextureButton = $QuitButton
@onready var menu_background: TextureRect = $MenuBackground
@onready var intro_anim: AnimationPlayer = $IntroSequence/IntroAnim
@onready var intro_1: TextureRect = $IntroSequence/Intro1
@onready var intro_2: TextureRect = $IntroSequence/Intro2
@onready var black_fade: ColorRect = $IntroSequence/BlackFade

var intro_steps = []
var current_step_index: int = 0
var skipping: bool = false
var step_timer: Timer = null

func _ready() -> void:
	# Hide everything initially
	black_fade.visible = false
	intro_1.visible = false
	intro_2.visible = false
	menu_background.visible = false
	play_button.visible = false
	quit_button.visible = false

	# Define steps: node, fade-in, fade-out, duration
	intro_steps = [
		{"node": black_fade, "fade_in": "BlackFade_FadeIn", "fade_out": "BlackFade_FadeOut", "duration": 1.0},
		{"node": intro_1, "fade_in": "Intro1_FadeIn", "fade_out": "Intro1_FadeOut", "duration": 10.0},
		{"node": intro_2, "fade_in": "Intro2_FadeIn", "fade_out": "Intro2_FadeOut", "duration": 10.0},
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
	intro_anim.play(step["fade_in"])

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
	intro_anim.play(step["fade_out"])


func _on_step_timer_timeout() -> void:
	# Timer finished: auto skip to fade-out
	skip_current_step()

func end_intro() -> void:
	# Show menu
	menu_background.visible = true
	play_button.visible = true
	quit_button.visible = true

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Level Scenes/level_1.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_intro_anim_animation_finished(anim_name: StringName) -> void:
	var step = intro_steps[current_step_index]

	if anim_name == step["fade_in"] and not skipping:
		# Start timer to auto-advance after duration
		step_timer.start(step["duration"])
	elif anim_name == step["fade_out"]:
		# Fade-out finished: hide node and go to next step
		step["node"].visible = false
		play_step(current_step_index + 1)
