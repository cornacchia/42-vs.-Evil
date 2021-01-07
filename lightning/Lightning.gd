extends Node2D

enum {
	IMMINENT,
	FIRST_FLASH,
	WAIT_SECOND_FLASH,
	SECOND_FLASH,
	WAIT_THIRD_FLASH
	THIRD_FLASH
}

# Global constants
var rng = RandomNumberGenerator.new()

# Global variables
var _state = IMMINENT

func play_thunder():
	match rng.randi_range(1, 3):
		1:
			$Thunder_1.play()
		2: 
			$Thunder_2.play()
		3: 
			$Thunder_3.play()

func start():
	self.position = get_parent().get_node('Objects/42').global_position
	_state = IMMINENT
	$Timer.wait_time = rng.randf_range(3.0, 10.0)
	$Timer.start()

func _on_Timer_timeout():
	match _state:
		IMMINENT:
			_state = FIRST_FLASH
			$Light2D.enabled = true
			$Timer.wait_time = rng.randf_range(0.3, 0.7)
			$Timer.start()
			play_thunder()
		FIRST_FLASH:
			_state = WAIT_SECOND_FLASH
			$Light2D.enabled = false
			$Timer.wait_time = rng.randf_range(0.5, 1.5)
			$Timer.start()
		WAIT_SECOND_FLASH:
			_state = SECOND_FLASH
			$Light2D.enabled = true
			$Timer.wait_time = rng.randf_range(0.1, 0.3)
			$Timer.start()
		SECOND_FLASH:
			_state = WAIT_THIRD_FLASH
			$Light2D.enabled = false
			$Timer.wait_time = rng.randf_range(0.1, 0.2)
			$Timer.start()
		WAIT_THIRD_FLASH:
			_state = THIRD_FLASH
			$Light2D.enabled = true
			$Timer.wait_time = rng.randf_range(0.1, 0.4)
			$Timer.start()
		THIRD_FLASH:
			_state = IMMINENT
			$Light2D.enabled = false
			start()

func _ready():
	rng.randomize()
