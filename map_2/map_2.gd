extends "res://map_1/map_1.gd"

func setup():
	CURRENT_SCENE = "res://map_2/map_2.tscn"
	NEXT_PUZZLE_SCENE = "res://map_puzzle_2_v2/puzzle_map_2.tscn"
	NEXT_SCENE = "res://cutscenes/Cutscene_Boss_Cop.tscn"
	MIN_MONSTERS = 40
	MAX_MONSTERS = 60

	MIN_TOMBS = 100
	MAX_TOMBS = 200

	# Trees
	MIN_TREES = 0
	MAX_TREES = 5

	# Map
	MAX_CELL_X = 41
	MAX_CELL_Y = 27

	# Map rooms
	ROOM_MAX_SIZE = 10
	ROOM_MIN_SIZE = 4
	MAX_ROOMS = 2

	CROW_SPAWN_TIMEOUT = [3, 10]
	ACTIVE_MONSTERS = [monster_1, monster_2]

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
	#$Rain.start()
	$Wind.play()
	$CrowSpawn.start(rng.randi_range(3, 10))
