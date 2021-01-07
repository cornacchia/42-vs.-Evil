extends Node2D

enum {
	CHASE,
	MOVE_AWAY
}

var rng = RandomNumberGenerator.new()
var player_node
var SPEED = 50
var _last_velocity = Vector2.RIGHT
var _damage = 5
var _state = CHASE

func move(delta):
	var direction = self.global_position.direction_to(player_node.global_position)
	if _state == CHASE:
		_last_velocity = direction
		self.translate(direction * delta * SPEED)
	elif _state == MOVE_AWAY:
		if self.global_position.distance_to(player_node.global_position) > 50:
			_state = CHASE
		else:
			self.translate(_last_velocity * delta * SPEED)

func animate():
	if _last_velocity.x < 0:
		if _last_velocity.y < 0:
			$Sprite/AnimationPlayer.play("back_left")
		else:
			$Sprite/AnimationPlayer.play("front_left")
	else:
		if _last_velocity.y < 0:
			$Sprite/AnimationPlayer.play("back_right")
		else:
			$Sprite/AnimationPlayer.play("front_right")

func _process(delta):
	move(delta)
	animate()

func _ready():
	rng.randomize()
	SPEED = SPEED * rng.randf_range(0.8, 1.5)
	player_node = get_node("../42")

func _on_Hurt_area_shape_entered(_area_id, area, _area_shape, _self_shape):
	if area.is_in_group('hitbox') and area.is_in_group('player'):
		var body = area.get_parent()
		body.hit(_damage, _last_velocity)
		_state = MOVE_AWAY
