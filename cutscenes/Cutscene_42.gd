extends Node2D

enum {
	IDLE,
	WALK,
	ANIMATION
}

export var SPEED = 200
var _state = IDLE
var _next_destination = Vector2(0, 0)
var _last_velocity = Vector2(-1, 0)
export var flip_x = false
var _destinations = [Vector2(512, 128), Vector2(640, 192), Vector2(576, 384), Vector2(448, 384), Vector2(384, 192)]
export var _destinations_index = 0
export var mute = false

func set_next_destination_index():
	_destinations_index = (_destinations_index + 1) % len(_destinations)
	set_destination(_destinations[_destinations_index])

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
	match _state:
		IDLE:
			if _last_velocity.x < 0:
				if _last_velocity.y < 0:
					$Sprite/AnimationPlayer.play("idle_back_left")
				else:
					$Sprite/AnimationPlayer.play("idle_front_left")
			else:
				if _last_velocity.y < 0:
					$Sprite/AnimationPlayer.play("idle_back_right")
				else:
					$Sprite/AnimationPlayer.play("idle_front_right")
		WALK:
			if _last_velocity.x < 0:
				if _last_velocity.y < 0:
					$Sprite/AnimationPlayer.play("run_back_left")
				else:
					$Sprite/AnimationPlayer.play("run_front_left")
			else:
				if _last_velocity.y < 0:
					$Sprite/AnimationPlayer.play("run_back_right")
				else:
					$Sprite/AnimationPlayer.play("run_front_right")
			if not $StepDirt.playing and not mute:
				$StepDirt.play()

func _process(delta):
	handle_state(delta)
	animate()

func _ready():
	if flip_x:
		$Sprite.flip_h = true

func say_something(key):
	$SpeechBaloon.text = tr(key)
	$SpeechBaloon.visible = true
	$SpeechBaloon/Timer.start()

func play_animation(anim):
	_state = ANIMATION
	$Sprite/AnimationPlayer.play(anim)

func _on_Timer_timeout():
	$SpeechBaloon.visible = false

func _on_AnimationPlayer_animation_finished(_anim_name):
	_state = IDLE
