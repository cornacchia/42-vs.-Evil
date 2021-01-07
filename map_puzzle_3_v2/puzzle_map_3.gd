extends Node2D

func gate_open():
	return "res://cutscenes/Cutscene_Necromancer.tscn"

func get_scene_path():
	return "res://map_puzzle_3_v2/puzzle_map_3.tscn"

func get_ground_type(_pos):
	return 'floor'

func setup():
	$Rain.play()
	$Objects/ExitGate.open()

func _ready():
	setup()
