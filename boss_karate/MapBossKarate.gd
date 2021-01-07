extends "res://map_1/map_1.gd"

func setup():
	CURRENT_SCENE = "res://boss_karate/MapBossKarate.tscn"
	initialize_constants()
	$Lightning.start()
	$CrowSpawn.start(rng.randi_range(3, 10))
