extends StaticBody2D

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	set_tree_type()

func set_tree_type():
	if rng.randf() < 0.5:
		$Sprite.frame_coords.x = 0
		$Sprite.frame_coords.y = 0
		$CollisionTree0.disabled = false
		$CollisionTree1.disabled = true
	else:
		$Sprite.frame_coords.x = 1
		$Sprite.frame_coords.y = 0
		$CollisionTree0.disabled = true
		$CollisionTree1.disabled = false
