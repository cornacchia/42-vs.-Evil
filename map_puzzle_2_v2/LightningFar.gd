extends Node2D

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	$Timer.start(rng.randf_range(3.0, 7.0))

func _on_Timer_timeout():
	var rand = rng.randi_range(0, 2)
	if rand == 0:
		$Thunder1.play()
	elif rand == 2:
		$Thunder2.play()
	elif rand == 3:
		$Thunder3.play()
	$Timer.start(rng.randf_range(3.0, 7.0))
