extends "res://monster_1/monster_1.gd"

func define_constants():
	SPEED = 100 * rng.randf_range(0.9, 1.2)
	_life = 200
	DAMAGE = 20
	DISTANCE_TO_ATTACK = 120
