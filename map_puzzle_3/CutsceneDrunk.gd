extends Node2D

func _ready():
	$Rain.start()
	$AnimationPlayer.play('cutscene_drunk')

func _on_AnimationPlayer_animation_finished(_anim_name):
	var err = get_tree().change_scene("res://map_puzzle_3/MapEvil42.tscn")
	if err != OK:
		print('Error changing scene')

func handle_input():
	if Input.is_action_just_pressed('ui_cancel'):
		var err = get_tree().change_scene("res://map_puzzle_3/MapEvil42.tscn")
		if err != OK:
			print('Error changing scene')

func _process(_delta):
	handle_input()
