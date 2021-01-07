extends "res://map_1/map_1.gd"

func setup():
	CURRENT_SCENE = "res://map_3/map_3.tscn"
	NEXT_PUZZLE_SCENE = "res://map_puzzle_3_v2/puzzle_map_3.tscn"
	NEXT_SCENE = "res://cutscenes/Cutscene_Necromancer.tscn"
	MIN_MONSTERS = 20
	MAX_MONSTERS = 40

	MIN_TOMBS = 20
	MAX_TOMBS = 100

	# Trees
	MIN_TREES = 60
	MAX_TREES = 100

	# Map
	MAX_CELL_X = 41
	MAX_CELL_Y = 27

	MAX_ROOMS = 0

	CROW_SPAWN_TIMEOUT = [1, 5]
	ACTIVE_MONSTERS = [monster_1, monster_2, monster_3]

	initialize_constants()
	generate_base_map()
	create_rooms(floor_tiles)
	generate_player()
	var occupied_positions = []
	occupied_positions = generate_crypt(occupied_positions)
	occupied_positions = generate_trees(occupied_positions)
	occupied_positions = generate_tombs(occupied_positions)
	occupied_positions = generate_monsters(occupied_positions)
	$Lightning.start()
	$Rain.start()
	$Wind.play()
	$CrowSpawn.start(rng.randi_range(3, 10))
