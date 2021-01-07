extends Node2D

enum {
	FLY,
	FLY_SKULL
}

onready var SKULL = preload("res://crow/Skull.tscn")

var map_node
var player_node
var _state = FLY_SKULL
var _last_velocity = Vector2(0, 0)
var rng = RandomNumberGenerator.new()
var SPEED = 150
var ATTACK_HEIGHT = 128
var DISTANCE_TO_HIT = 0

func drop_skull():
	var skull = SKULL.instance()
	var destination = self.global_position + Vector2(0, ATTACK_HEIGHT * rng.randf_range(0.5, 1.5))
	skull.setup(self.global_position, destination)
	get_node('../').call_deferred('add_child', skull)
	_state = FLY

func go_to_player(delta):
	var destination = player_node.global_position + Vector2(0, ATTACK_HEIGHT * -1)
	if abs(self.global_position.x - destination.x) < DISTANCE_TO_HIT:
		drop_skull()
	else:
		var direction = self.global_position.direction_to(destination)
		_last_velocity = direction
		self.translate(direction * delta * SPEED)

func get_out_of_map(delta):
	if self.global_position.distance_to(player_node.global_position) < 800:
		self.translate(_last_velocity * delta * SPEED)
	else:
		queue_free()

func handle_state(delta):
	match _state:
		FLY_SKULL:
			go_to_player(delta)
		FLY:
			get_out_of_map(delta)

func animate():
	match _state:
		FLY_SKULL:
			if _last_velocity.x < 0:
				$Sprite/AnimationPlayer.play("fly_left_skull")
			else:
				$Sprite/AnimationPlayer.play("fly_right_skull")
		FLY:
			if _last_velocity.x < 0:
				$Sprite/AnimationPlayer.play("fly_left")
			else:
				$Sprite/AnimationPlayer.play("fly_right")

func _process(delta):
	handle_state(delta)
	animate()

func _ready():
	rng.randomize()
	DISTANCE_TO_HIT = rng.randi_range(5, 100)
	$Caw.play()
	map_node = get_node('../../')
	player_node = get_node("../42")
