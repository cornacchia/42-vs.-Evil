extends Node2D

func _ready():
	$AnimationPlayer.play('cutscene')
	$Rain.start()
	$Lightning.start()

func _on_AnimationPlayer_animation_finished(_anim_name):
	var err = get_tree().change_scene("res://map_3/map_3.tscn")
	if err != OK:
		print('Error changing scene')

func handle_input():
	if Input.is_action_just_pressed('ui_cancel'):
		var err = get_tree().change_scene("res://map_3/map_3.tscn")
		if err != OK:
			print('Error changing scene')

func _process(_delta):
	handle_input()
