extends "res://map_1/map_1.gd"

func generate_ghosts():
	if ($Fog.visible):
		$Fog.visible = false
		$RedFog.visible = true
	if not $HeartBeat.playing:
		$HeartBeat.play()
	# Create new ghost
	number_of_ghosts = 2
	var new_ghost_1 = ghost.instance()
	var new_ghost_2 = ghost.instance()
	new_ghost_1.position = Vector2(-50, -50)
	new_ghost_2.position = Vector2(700, -50)
	$Objects.call_deferred('add_child', new_ghost_1)
	$Objects.call_deferred('add_child', new_ghost_2)
	$SpawnGhost.play()
	ghosts[new_ghost_1.get_name()] = new_ghost_1
	ghosts[new_ghost_2.get_name()] = new_ghost_2
	# Create new ghost bones
	var new_ghost_bones_1 = ghost_bones.instance()
	var new_ghost_bones_2 = ghost_bones.instance()
	new_ghost_bones_1.position = Vector2(100, -100)
	new_ghost_bones_2.position = Vector2(-100, 500)
	new_ghost_bones_1.set_id(new_ghost_1.get_name())
	new_ghost_bones_2.set_id(new_ghost_2.get_name())
	$Objects.call_deferred('add_child', new_ghost_bones_1)
	$Objects.call_deferred('add_child', new_ghost_bones_2)

func setup():
	PLAYER_LIGHT_FADE = false
	CROW_SPAWN_TIMEOUT = [2, 5]
	MAX_CELL_X = 16
	MAX_CELL_Y = 9
	initialize_constants()
	$Lightning.start()
	$Rain.start()
	$CrowSpawn.start(rng.randi_range(3, 10))
	generate_ghosts()
