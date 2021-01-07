extends "res://map_1/map_1.gd"

func generate_bottles():
	for i in range(1, MAX_CELL_X):
		for j in range(1, MAX_CELL_Y):
			var new_bottle = bottle.instance()
			new_bottle.position = Vector2(i * 64, j * 64)
			$Objects.call_deferred('add_child', new_bottle)

func setup():
	MAX_CELL_X = 16
	MAX_CELL_Y = 9
	initialize_constants()
	generate_base_map()
	generate_bottles()
	generate_player()
	$Lightning.start()
	$Rain.start()
