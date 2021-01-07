extends "res://tomb/TombFront.gd"

func setup():
	$Tomb.frame_coords = Vector2(0, 3)
	frames = [[1, 3], [2, 3], [3, 3]]
	if rng.randf() < 0.5:
		$Tomb.frame_coords = Vector2(0, 1)
		frames = [[1, 1], [2, 1], [3, 1]]
	if options['indoor']:
		$Ground.frame_coords = Vector2(9, 1)
	else:
		$Ground.frame_coords = Vector2(9, 0)
