extends Node2D

func _ready():
	$CreditsSong.play()
	$Timer.start()

func _process(delta):
	handle_input()
	$GoUp.translate(Vector2.UP * delta * 25)

func _on_CreditsSong_finished():
	var err = get_tree().change_scene("res://menu/MainMenu.tscn")
	if err != OK:
		print('Error changing scene')

func handle_input():
	if Input.is_action_just_pressed('ui_cancel'):
		var err = get_tree().change_scene("res://menu/MainMenu.tscn")
		if err != OK:
			print('Error changing scene')

func _on_Timer_timeout():
	$AnimationPlayer.play('cutscene')
