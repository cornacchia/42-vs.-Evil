extends "res://map_1/map_1.gd"

var MAX_MAZE_CELL_X
var MAX_MAZE_CELL_Y

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
	var pos_x = 64 + j * 96 + r_j * 32
	var pos_y = 64 + i * 96 + r_i * 32
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
	var player_cell_x = floor(PLAYER_START.x / 96) - 1
	var player_cell_y = floor(PLAYER_START.y / 96) - 1
	var l = [player_cell_y, player_cell_x]
	var s = [player_cell_y, player_cell_x]
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
	MAX_CELL_X = 31
	MAX_CELL_Y = 31
	MAX_MAZE_CELL_X = floor(MAX_CELL_X / 1.5)
	MAX_MAZE_CELL_Y = floor(MAX_CELL_Y / 1.5)
	CROW_SPAWN_TIMEOUT = [2, 7]
	initialize_constants()
	generate_base_map()
	var maze = create_maze()
	draw_tombs(maze)
	generate_player()
	$Lightning.start()
	$CrowSpawn.start(rng.randi_range(3, 5))
