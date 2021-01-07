extends Node2D

# Global constants
var rng = RandomNumberGenerator.new()

# Monsters
var MIN_MONSTERS = 10
var MAX_MONSTERS = 30
var ACTIVE_MONSTERS = []

# Tombs
var MIN_TOMBS = 10
var MAX_TOMBS = 30

# Trees
var MIN_TREES = 3
var MAX_TREES = 20

# Map
var MAX_CELL_X = 31
var MAX_CELL_Y = 17

# Map rooms
var ROOM_MAX_SIZE = 6
var ROOM_MIN_SIZE = 2
var MAX_ROOMS = 5

var PLAYER_START = Vector2(128, 128)
var GATES = {}

var CROW_SPAWN_TIMEOUT = [5, 15]

var PLAYER_LIGHT_FADE = true
var special_tomb_placed = false

var golden_key_given = false

var NEXT_SCENE
var NEXT_PUZZLE_SCENE
var CURRENT_SCENE = "res://map_1/map_1.tscn"

# Global variables
onready var player_42 = preload("res://42/42.tscn")
onready var monster_1 = preload("res://monster_1/monster_1.tscn")
onready var monster_2 = preload("res://monster_2/monster_2.tscn")
onready var monster_3 = preload("res://monster_3/monster_3.tscn")
onready var ghost = preload("res://ghost/Ghost.tscn")
onready var ghost_bones = preload("res://ghost/GhostBones.tscn")
onready var crow = preload("res://crow/Crow.tscn")
onready var boss_1 = preload("res://boss_1/boss_1.tscn")
onready var tomb_front = preload("res://tomb/TombFront.tscn")
onready var tomb_back = preload("res://tomb/TombBack.tscn")
onready var tree = preload("res://tree/Tree.tscn")
onready var bottle = preload("res://bottle/Bottle.tscn")
onready var gate_north = preload("res://gate/GateFront.tscn")
onready var crypt = preload("res://crypt/Crypt.tscn")

var void_tile
var grass_tiles
var floor_tiles
var walls = {}
var number_of_ghosts = 0
var ghosts = {}

func get_scene_path():
	return CURRENT_SCENE

func initialize_constants():
	void_tile = $Objects/Ground.tile_set.find_tile_by_name('void')
	grass_tiles = [
		$Objects/Ground.tile_set.find_tile_by_name('grass_1'),
		$Objects/Ground.tile_set.find_tile_by_name('grass_2'),
		$Objects/Ground.tile_set.find_tile_by_name('grass_3')
	]
	floor_tiles = [
		$Objects/Ground.tile_set.find_tile_by_name('floor_1'),
		$Objects/Ground.tile_set.find_tile_by_name('floor_2'),
		$Objects/Ground.tile_set.find_tile_by_name('floor_3')
	]
	walls['tl'] = $Objects/Walls.tile_set.find_tile_by_name('cemetery_wall_tl')
	walls['tr'] = $Objects/Walls.tile_set.find_tile_by_name('cemetery_wall_tr')
	walls['bl'] = $Objects/Walls.tile_set.find_tile_by_name('cemetery_wall_bl')
	walls['br'] = $Objects/Walls.tile_set.find_tile_by_name('cemetery_wall_br')
	walls['t'] = $Objects/Walls.tile_set.find_tile_by_name('cemetery_wall_t')
	walls['b'] = $Objects/Walls.tile_set.find_tile_by_name('cemetery_wall_b')
	walls['l'] = $Objects/Walls.tile_set.find_tile_by_name('cemetery_wall_l')
	walls['r'] = $Objects/Walls.tile_set.find_tile_by_name('cemetery_wall_r')

func crypt_open():
	return NEXT_PUZZLE_SCENE

func gate_open():
	return NEXT_SCENE

func get_ground_type(position):
	var cell_x = floor(position.x / 64)
	var cell_y = floor(position.y / 64)
	var cell_id = $Objects/Ground.get_cell(cell_x, cell_y)
	if cell_id in grass_tiles:
		return 'grass'
	elif cell_id in floor_tiles:
		return 'floor'
	else:
		return 'none'

func get_random_position():
	var p_x = rng.randi_range(1, MAX_CELL_X - 1)
	var p_y = rng.randi_range(1, MAX_CELL_Y - 1)

	return Vector2((p_x * 64), (p_y * 64))

func create_room(room, tiles):
	for x in range(room['x1'] + 1, room['x2']):
		for y in range(room['y1'] + 1, room['y2']):
			var tile_index = rng.randi_range(1, len(tiles) - 1)
			$Objects/Ground.set_cell(x, y, tiles[tile_index])

func create_h_tunnel(x1, x2, y, tiles):
	for x in range(min(x1, x2), max(x1, x2) + 1):
		var tile_index = rng.randi_range(1, len(tiles) - 1)
		$Objects/Ground.set_cell(x, y, tiles[tile_index])

func create_v_tunnel(y1, y2, x, tiles):
	for y in range(min(y1, y2), max(y1, y2) + 1):
		var tile_index = rng.randi_range(1, len(tiles) - 1)
		$Objects/Ground.set_cell(x, y, tiles[tile_index])

func rect_center(rect):
	var center_x = int((rect['x1'] + rect['x2']) / 2)
	var center_y = int((rect['y1'] + rect['y2']) / 2)
	return [center_x, center_y]

func intersect(rect1, rect2):
   return (rect1['x1'] <= rect2['x2'] and rect1['x2'] >= rect2['x1'] and
		   rect1['y1'] <= rect2['y2'] and rect1['y2'] >= rect2['y1'])

func create_rooms(tiles):
	var rooms = []
	var num_rooms = 0
	for _r in range(MAX_ROOMS):
		# random width and height
		var w = rng.randi_range(ROOM_MIN_SIZE, ROOM_MAX_SIZE)
		var h = rng.randi_range(ROOM_MIN_SIZE, ROOM_MAX_SIZE)
		# random position without going out of the boundaries of the map
		var x = rng.randi_range(1, MAX_CELL_X - w - 1)
		var y = rng.randi_range(1, MAX_CELL_Y - h - 1)

		var new_room = {'x1': x, 'x2': x + w, 'y1': y, 'y2': y + h}

		for other_room in rooms:
			if intersect(new_room, other_room):
				break

		create_room(new_room, tiles)

		# center coordinates of new room, will be useful later
		var room_center = rect_center(new_room)
		if num_rooms > 0:
			var prev_room_center = rect_center(rooms[num_rooms - 1])

			# flip a coin (random number that is either 0 or 1)
			if rng.randi_range(0, 1) == 1:
				# first move horizontally, then vertically
				create_h_tunnel(prev_room_center[0], room_center[0], prev_room_center[1], tiles)
				create_v_tunnel(prev_room_center[1], room_center[1], room_center[0], tiles)
			else:
				# first move vertically, then horizontally
				create_v_tunnel(prev_room_center[1], room_center[1], prev_room_center[0], tiles)
				create_h_tunnel(prev_room_center[0], room_center[0], room_center[1], tiles)
		# finally, append the new room to the list
		rooms.append(new_room)
		num_rooms += 1

func generate_base_map():
	# Draw emptiness
	for c_i in range(-30, MAX_CELL_X + 30):
		for c_j in range(-30, MAX_CELL_Y + 30):
			$Objects/Ground.set_cell(c_i, c_j, void_tile)
	# Draw floor
	for c_i in range(1, MAX_CELL_X):
		for c_j in range(1, MAX_CELL_Y):
			var tile_index = rng.randi_range(1, len(grass_tiles) - 1)
			$Objects/Ground.set_cell(c_i, c_j, grass_tiles[tile_index])
	# Draw map walls
	$Objects/Walls.set_cell(0, 0, walls['tl'])
	$Objects/Walls.set_cell(MAX_CELL_X, 0, walls['tr'])
	$Objects/Walls.set_cell(0, MAX_CELL_Y - 1, walls['bl'])
	$Objects/Walls.set_cell(MAX_CELL_X, MAX_CELL_Y - 1, walls['br'])
	var gate_north_pos_x = rng.randi_range(4, MAX_CELL_X - 4)
	var gate_south_pos_x = rng.randi_range(4, MAX_CELL_X - 4)
	for c_i in range(1, MAX_CELL_X):
		var wall_north = true
		var wall_south = true
		if c_i == gate_north_pos_x:
			wall_north = false
			GATES['north'] = gate_north.instance()
			GATES['north'].position = Vector2(c_i * 64, 64)
			$Objects.call_deferred('add_child', GATES['north'])
		elif c_i == gate_north_pos_x + 1:
			wall_north = false
		if c_i == gate_south_pos_x:
			wall_south = false
			GATES['south'] = gate_north.instance()
			GATES['south'].position = Vector2(c_i * 64, MAX_CELL_Y * 64)
			PLAYER_START = Vector2((c_i * 64) + 64, (MAX_CELL_Y - 1) * 64)
			$Objects.call_deferred('add_child', GATES['south'])
		elif c_i == gate_south_pos_x + 1:
			wall_south = false
		if wall_north:
			$Objects/Walls.set_cell(c_i, 0, walls['t'])
		if wall_south:
			$Objects/Walls.set_cell(c_i, MAX_CELL_Y - 1, walls['b'])
	for c_j in range(1, MAX_CELL_Y - 1):
		$Objects/Walls.set_cell(0, c_j, walls['l'])
		$Objects/Walls.set_cell(MAX_CELL_X, c_j, walls['r'])

func generate_player():
	var player = player_42.instance()
	player.position = Vector2(PLAYER_START.x, PLAYER_START.y)
	if not PLAYER_LIGHT_FADE:
		player.stop_reducing_light()
	$Objects.add_child(player, true)

func generate_crypt(occupied_positions):
	var cell_x = rng.randi_range(2, MAX_CELL_X - 4)
	var cell_y = rng.randi_range(4, MAX_CELL_Y - 4)
	for i in range(-1, 2):
		for j in range(-1, 2):
			var x = (cell_x * 64) + (i * 64)
			var y = (cell_y * 64) + (j * 64)
			occupied_positions.append(Vector2(x, y))
	var new_crypt = crypt.instance()
	new_crypt.position = Vector2(cell_x * 64, cell_y * 64)
	$Objects.call_deferred('add_child', new_crypt)
	return occupied_positions
	
func generate_trees(occupied_positions):
	var number_of_trees = rng.randi_range(MIN_TREES, MAX_TREES)
	for _i in range(number_of_trees):
		var free = false
		var cell_1
		var cell_2
		while !free:
			var cell_x = rng.randi_range(2, MAX_CELL_X - 2)
			var cell_y = rng.randi_range(2, MAX_CELL_Y - 2)

			cell_1 = Vector2((cell_x * 64), (cell_y * 64))
			cell_2 = Vector2((cell_x * 64) + 64, (cell_y * 64))
			if (cell_1 in occupied_positions or cell_2 in occupied_positions):
				continue
			if (get_ground_type(cell_1) == 'floor' or get_ground_type(cell_2) == 'floor'):
				continue
			free = true

		var new_tree = tree.instance()

		occupied_positions.append(cell_1)
		occupied_positions.append(cell_2)
		new_tree.position = cell_1
		$Objects.call_deferred('add_child', new_tree)
	return occupied_positions

func generate_tombs(occupied_positions):
	var number_of_tombs = rng.randi_range(MIN_TOMBS, MAX_TOMBS)
	for _i in range(number_of_tombs):
		var tomb_type = 'front'
		if (rng.randf() < 0.5):
			tomb_type = 'back'
		var row_length = rng.randi_range(2, 5)
		var start_cell_x = rng.randi_range(2, MAX_CELL_X - 2)
		var start_cell_y = rng.randi_range(2, MAX_CELL_Y - 2)
		var offset = 0
		for _j in range(row_length):
			var new_position = Vector2((start_cell_x * 64) + offset, (start_cell_y * 64))
			if (new_position in occupied_positions):
				break
			if (get_ground_type(new_position + Vector2(-16, -16)) == 'floor'):
				break
			if (get_ground_type(new_position + Vector2(16, 16)) == 'floor'):
				break
			if (new_position.y >= MAX_CELL_Y * 64):
				break
			var new_tomb
			if tomb_type == 'front':
				 new_tomb = tomb_front.instance()
			else:
				new_tomb = tomb_back.instance()
			offset += 32
			occupied_positions.append(new_position)
			new_tomb.position = new_position
			if not special_tomb_placed and tomb_type == 'front':
				new_tomb.options['special'] = true
				special_tomb_placed = true
			$Objects.call_deferred('add_child', new_tomb)
	return occupied_positions

func generate_monsters(occupied_positions):
	var number_of_monsters = rng.randi_range(MIN_MONSTERS, MAX_MONSTERS)
	for _i in range(number_of_monsters):
		var monster_type = rng.randi_range(0, len(ACTIVE_MONSTERS) - 1)
		var new_monster = ACTIVE_MONSTERS[monster_type].instance()
		if not golden_key_given:
			golden_key_given = true
			new_monster.key = true
		var free = false
		while !free:
			var new_monster_cell_x = rng.randi_range(1, MAX_CELL_X - 1)
			var new_monster_cell_y = rng.randi_range(1, MAX_CELL_Y - 1)

			var new_position = Vector2((new_monster_cell_x * 64) + 32, (new_monster_cell_y * 64) + 32)
			if (new_position in occupied_positions):
				continue
			free = true
			occupied_positions.append(new_position)
			new_monster.position = new_position
			$Objects.call_deferred('add_child', new_monster)
	return occupied_positions

func spawn_ghost():
	if ($Fog.visible):
		$Fog.visible = false
		$RedFog.visible = true
	if not $HeartBeat.playing:
		$HeartBeat.play()
	# Create new ghost
	number_of_ghosts += 1
	var cell_x = rng.randi_range(1, MAX_CELL_X - 1)
	var cell_y = rng.randi_range(1, MAX_CELL_Y - 1)
	var new_position = Vector2((cell_x * 64), (cell_y * 64))
	var new_ghost = ghost.instance()
	new_ghost.position = new_position
	$Objects.call_deferred('add_child', new_ghost)
	$SpawnGhost.play()
	ghosts[new_ghost.get_instance_id()] = new_ghost
	# Create new ghost bones
	var bones_cell_x = rng.randi_range(1, MAX_CELL_X - 1)
	var bones_cell_y = rng.randi_range(1, MAX_CELL_Y - 1)
	var new_bones_position = Vector2((bones_cell_x * 64), (bones_cell_y * 64))
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

func boss_dead():
	$Objects/ExitGate.open()

func setup():
	NEXT_PUZZLE_SCENE = "res://map_puzzle_1_v2/puzzle_map_1.tscn"
	NEXT_SCENE = "res://cutscenes/Cutscene_Boss_Karate.tscn"
	ACTIVE_MONSTERS = [monster_1]
	initialize_constants()
	generate_base_map()
	create_rooms(floor_tiles)
	generate_player()
	var occupied_positions = []
	occupied_positions = generate_crypt(occupied_positions)
	occupied_positions = generate_trees(occupied_positions)
	occupied_positions = generate_tombs(occupied_positions)
	occupied_positions = generate_monsters(occupied_positions)
	$Wind.play()
	$CrowSpawn.start(rng.randi_range(3, 10))

func _ready():
	rng.randomize()
	setup()

func _on_CrowSpawn_timeout():
	var new_crow = crow.instance()
	var cell_y = rng.randi_range(1, MAX_CELL_Y - 1)
	var x_pos = rng.randf()
	if x_pos < 0.5:
		new_crow.position = Vector2(0, (cell_y * 64))
	else:
		new_crow.position = Vector2((MAX_CELL_X * 64), (cell_y * 64))
	$Objects.call_deferred('add_child', new_crow)
	$CrowSpawn.start(rng.randi_range(CROW_SPAWN_TIMEOUT[0], CROW_SPAWN_TIMEOUT[1]))
