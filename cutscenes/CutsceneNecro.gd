extends Node2D

enum {
	IDLE,
	WALK
}

var SPEED = 200
var _state = IDLE
var _next_destination = Vector2(0, 0)
var _last_velocity = Vector2(-1, 0)
export var flip_x = false

func play_animation(name):
	$Sprite/AnimationPlayer.play(name)

func play_animation_back(name):
	$Sprite/AnimationPlayer.play_backwards(name)

func set_destination(new_destination):
	_next_destination = new_destination
	_state = WALK

func move_to_destination(delta):
	if (self.global_position.distance_to(_next_destination) > 5):
		var direction = self.global_position.direction_to(_next_destination)
		_last_velocity = direction
		self.translate(direction * delta * SPEED)
	else:
		_state = IDLE

func handle_state(delta):
	match(_state):
		WALK:
			move_to_destination(delta)

func animate():
	if _last_velocity.x < 0:
		$Sprite/AnimationPlayer.play("idle_left")
	else:
		$Sprite/AnimationPlayer.play("idle_right")

func _process(delta):
	handle_state(delta)
	animate()

func _ready():
	if flip_x:
		$Sprite.flip_h = true

func say_something(text):
	$SpeechBaloon.text = text
	$SpeechBaloon.visible = true
	$SpeechBaloon/Timer.start()

func _on_Timer_timeout():
	$SpeechBaloon.visible = false
