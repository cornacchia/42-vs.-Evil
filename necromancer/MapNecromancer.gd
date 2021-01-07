extends "res://map_1/map_1.gd"

func setup():
	CURRENT_SCENE = "res://necromancer/MapNecromancer.tscn"
	initialize_constants()
	$Lightning.start()
	$Rain.start()
	$CrowSpawn.start(rng.randi_range(3, 10))
