extends "res://map_1/map_1.gd"

func setup():
	CURRENT_SCENE = "res://boss_cop/MapBossCop.tscn"
	initialize_constants()
	$Lightning.start()
	$Rain.start()
