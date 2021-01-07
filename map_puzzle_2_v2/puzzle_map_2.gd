extends Node2D

onready var tomb_front = preload("res://tomb/TombFront.tscn")
onready var ghost = preload("res://ghost/Ghost.tscn")
onready var ghost_bones = preload("res://ghost/GhostBones.tscn")
onready var crow = preload("res://crow/Crow.tscn")

var rng = RandomNumberGenerator.new()

var MAX_MAZE_CELL_X = 20
var MAX_MAZE_CELL_Y = 20
var CROW_SPAWN_TIMEOUT = [2, 5]

var ghosts = {}
var number_of_ghosts = 0

func gate_open():
	return "res://cutscenes/Cutscene_Boss_Cop.tscn"

func get_scene_path():
	return "res://map_puzzle_2_v2/puzzle_map_2.tscn"

func get_ground_type(_pos):
	return 'floor'

func spawn_ghost():
	$RedFog.visible = true
	if not $HeartBeat.playing:
		$HeartBeat.play()
	# Create new ghost
	number_of_ghosts += 1
	var cell_x = rng.randi_range(0, MAX_MAZE_CELL_X)
	var cell_y = rng.randi_range(0, MAX_MAZE_CELL_Y)
	var pos_x = (2 * 64) + cell_x * 96 + 32
	var pos_y = (5 * 64) + cell_y * 96 + 32
	var new_position = Vector2(pos_x, pos_y)
	var new_ghost = ghost.instance()
	new_ghost.position = new_position
	$Objects.call_deferred('add_child', new_ghost)
	$SpawnGhost.play()
	ghosts[new_ghost.get_instance_id()] = new_ghost
	# Create new ghost bones
	var bones_cell_x = rng.randi_range(0, MAX_MAZE_CELL_X)
	var bones_cell_y = rng.randi_range(0, MAX_MAZE_CELL_Y)
	var pos_bones_x = (2 * 64) + cell_x * 96 + 48
	var pos_bones_y = (5 * 64) + cell_y * 96 + 48
	var new_bones_position = Vector2(pos_bones_x, pos_bones_y)
	var new_ghost_bones = ghost_bones.instance()
	new_ghost_bones.set_id(new_ghost.get_instance_id())
	new_ghost_bones.position = new_bones_position
	$Objects.call_deferred('add_child', new_ghost_bones)
	$UI.update_ghosts(number_of_ghosts)

func remove_ghost(ghost_id):
	ghosts[ghost_id].queue_free()
	$KillGhost.play()
	number_of_ghosts -= 1
	if (number_of_ghosts <= 0):
		$Fog.visible = true
		$RedFog.visible = false
		$HeartBeat.stop()
	$UI.update_ghosts(number_of_ghosts)

func check_boundaries(x, y):
	if x > MAX_MAZE_CELL_X - 1  or x < 0 or y > MAX_MAZE_CELL_Y - 1 or y < 0:
		return false
	return true

func gen_random_off():
	if rng.randf() < 0.5:
		return -1
	else:
		return 1

func generate_neigh(s):
	var neigh = rng.randi_range(1, 4)
	if (neigh == 1):
		return [s[0], s[1] - 1]
	elif (neigh == 2):
		return [s[0] + 1, s[1]]
	elif (neigh == 3):
		return [s[0], s[1] + 1]
	else:
		return [s[0] - 1, s[1]]

func pick_random_neigh(s):
	var neigh = generate_neigh(s)
	while not check_boundaries(neigh[0], neigh[1]):
		neigh = generate_neigh(s)
	return neigh

func open_walls(l, s, maze):
	maze[s[0]][s[1]][0] = true
	var off_y = s[0] - l[0]
	var off_x = s[1] - l[1]
	if off_x < 0:
		maze[s[0]][s[1]][2] = 0
		maze[l[0]][l[1]][4] = 0
	if off_x > 0:
		maze[s[0]][s[1]][4] = 0
		maze[l[0]][l[1]][2] = 0
	if off_y < 0:
		maze[s[0]][s[1]][3] = 0
		maze[l[0]][l[1]][1] = 0
	if off_y > 0:
		maze[s[0]][s[1]][1] = 0
		maze[l[0]][l[1]][3] = 0

func draw_tomb(i, j, r_i, r_j):
	var new_tomb = tomb_front.instance()
	new_tomb.options['indoor'] = true
	var pos_x = (2 * 64) + j * 96 + r_j * 32
	var pos_y = (5 * 64) + i * 96 + r_i * 32
	new_tomb.position = Vector2(pos_x, pos_y)
	$Objects.call_deferred('add_child', new_tomb)

func draw_maze_cell(cell, i, j):
	if i > 0:
		draw_tomb(i, j, 0, 0)
		draw_tomb(i, j, 0, 2)
	draw_tomb(i, j, 2, 0)
	draw_tomb(i, j, 2, 2)
	if cell[1] == 1 and i > 0:
		draw_tomb(i, j, 0, 1)
	if cell[2] == 1:
		draw_tomb(i, j, 1, 2)
	if cell[3] == 1:
		draw_tomb(i, j, 2, 1)
	if cell[4] == 1:
		draw_tomb(i, j, 1, 0)

func draw_tombs(maze):
	for i in range(len(maze)):
		for j in range(len(maze[i])):
			draw_maze_cell(maze[i][j], i, j)

func create_maze():
	var visited_count = 0
	var l = [19, 10]
	var s = [19, 10]
	var maze = []
	for i in range(MAX_MAZE_CELL_X):
		maze.append([])
		for j in range(MAX_MAZE_CELL_Y):
			maze[i].append([false, 1, 1, 1, 1])
	maze[s[0]][s[1]][0] = true
	visited_count += 1
	s = pick_random_neigh(s)
	while visited_count < (len(maze) * len(maze[0])):
		if not maze[s[0]][s[1]][0]:
			visited_count += 1
			open_walls(l, s, maze)
		l[0] = s[0]
		l[1] = s[1]
		s = pick_random_neigh(s)
	return maze

func setup():
	var maze = create_maze()
	draw_tombs(maze)
	$Objects/ExitGate.open()

func _ready():
	rng.randomize()
	setup()
	$CrowSpawn.start(rng.randi_range(CROW_SPAWN_TIMEOUT[0], CROW_SPAWN_TIMEOUT[1]))

func _on_CrowSpawn_timeout():
	var new_crow = crow.instance()
	new_crow.position = Vector2(0, 512)
	$Objects.call_deferred('add_child', new_crow)
	$CrowSpawn.start(rng.randi_range(CROW_SPAWN_TIMEOUT[0], CROW_SPAWN_TIMEOUT[1]))
