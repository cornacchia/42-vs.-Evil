extends "res://map_1/map_1.gd"

func gate_open():
	return "res://cutscenes/Cutscene_Necromancer.tscn"

func setup():
	CURRENT_SCENE = "res://map_puzzle_3/MapEvil42.tscn"
	$Objects.get_node('42').set_drunkenness(60)
	initialize_constants()
	$Lightning.start()
	$Rain.start()
