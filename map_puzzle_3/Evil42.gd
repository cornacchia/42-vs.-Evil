extends KinematicBody2D

onready var BULLET = preload("res://bullet/bullet.tscn")

const SHOOT_ANIMATIONS = [
	"shoot_front_right", "shoot_down_right", "shoot_back_right", "shoot_up_right",
	"shoot_front_left", "shoot_down_left", "shoot_back_left", "shoot_up_left"
]

enum {
	CHASE,
	SHOOT,
	SHOOTING,
	DIE,
	DEAD
}

var SPEED = 250
var _damage = 5
var _life = 200

var rng = RandomNumberGenerator.new()
var map_node
var player_node
var _state = CHASE
var _last_velocity = Vector2.RIGHT
var _orientation = Vector2.LEFT

func shoot_bullet(direction):
	var bullet = BULLET.instance()
	if (direction.x > 0):
		bullet.setup(_damage, direction, $ShootPositionEast.global_position)
	elif (direction.x < 0):
		bullet.setup(_damage, direction, $ShootPositionWest.global_position)
	elif (direction.y < 0):
		bullet.setup(_damage, direction, $ShootPositionNorth.global_position)
	elif (direction.y > 0):
		bullet.setup(_damage, direction, $ShootPositionSouth.global_position)
	get_node('../').call_deferred('add_child', bullet)

func shoot():
	var direction = self.global_position.direction_to(player_node.global_position)
	if _orientation.x > 0:
		if _orientation.y > 0:
			if direction.x > 0:
				$Sprite/AnimationPlayer.play("shoot_front_right")
			else:
				$Sprite/AnimationPlayer.play("shoot_down_right")
		else:
			if direction.x > 0:
				$Sprite/AnimationPlayer.play("shoot_back_right")
			else:
				$Sprite/AnimationPlayer.play("shoot_up_right")
	else:
		if _orientation.y > 0:
			if direction.x < 0:
				$Sprite/AnimationPlayer.play("shoot_front_left")
			else:
				$Sprite/AnimationPlayer.play("shoot_down_left")
		else:
			if direction.x < 0:
				$Sprite/AnimationPlayer.play("shoot_back_left")
			else:
				$Sprite/AnimationPlayer.play("shoot_up_left")
	_state = SHOOTING

func update_velocity(direction, delta):
	var velocity = direction.normalized() * SPEED * delta
	if (velocity.x != 0 or velocity.y != 0):
		_last_velocity = velocity
	if (velocity.x > 0):
		_orientation.x = 1
	elif (velocity.x < 0):
		_orientation.x = -1
	elif (velocity.y > 0):
		_orientation.y = 1
	elif (velocity.y < 0):
		_orientation.y = -1
	return velocity

func chase(delta, velocity):
	var direction = player_node.global_position - self.global_position
	if (abs(direction.y) < 10 or abs(direction.x) < 10):
		shoot()
	else:
		velocity = update_velocity(direction, delta)
	return velocity

func die():
	self.visible = false
	$Sprite/AnimationPlayer.stop()
	$WallCollision.set_deferred('disabled', true)
	$HitBox/CollisionShape2D.set_deferred('disabled', true)
	set_physics_process(false)
	_state = DEAD
	get_node('../../').boss_dead()

func hit(damage, _direction):
	_life -= damage
	if (_life > 0):
		$Hurt.play()
	else:
		$Dead.play()
		_state = DIE
		die()

func play_walk_sound():
	var feet_position = self.global_position + Vector2(0, 32)
	var ground_type = map_node.get_ground_type(feet_position)
	if ground_type == 'grass':
		if not $StepDirt.playing:
			$StepDirt.play()
	elif ground_type == 'floor':
		if not $StepFloor.playing:
			$StepFloor.play()

func handle_state(delta):
	var velocity = Vector2()
	match _state:
		CHASE:
			velocity = chase(delta, velocity)
			play_walk_sound()
	return velocity

func animate_run(direction):
	if direction.x < 0:
		if direction.y < 0:
			$Sprite/AnimationPlayer.play("run_back_left")
		else:
			$Sprite/AnimationPlayer.play("run_front_left")
	else:
		if direction.y < 0:
			$Sprite/AnimationPlayer.play("run_back_right")
		else:
			$Sprite/AnimationPlayer.play("run_front_right")

func animate():
	match _state:
		CHASE:
			var direction = self.global_position.direction_to(player_node.global_position)
			animate_run(direction)

func handle_sprite_offset():
	if ($Sprite.offset.x > 0 and _last_velocity.x < 0):
		$Sprite.offset = Vector2(-8, 0)
	elif ($Sprite.offset.x < 0 and _last_velocity.x >= 0):
		$Sprite.offset = Vector2(8, 0)

func _physics_process(delta):
	var velocity = handle_state(delta)
	handle_sprite_offset()
	animate()
	var _collision = move_and_collide(velocity)

func _ready():
	rng.randomize()
	map_node = get_node('../../')
	player_node = get_node("../42")

func _on_AnimationPlayer_animation_finished(anim_name):
	if SHOOT_ANIMATIONS.has(anim_name):
		$ReloadTimer.start(rng.randf_range(0.2, 0.8))

func _on_ReloadTimer_timeout():
	_state = CHASE
