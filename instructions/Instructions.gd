extends Node2D

func _ready():
	$Objects/Steel.setup('steel')
	$Objects/Gold.setup('gold')

func handle_input():
	if Input.is_action_just_pressed('ui_shoot'):
		var err = get_tree().change_scene("res://map_1/map_1.tscn")
		if err != OK:
			print('Error loading scene!')
func _process(_delta):
	handle_input()
