extends KinematicBody2D

enum {
	IDLE,
	CHASE,
	LOST,
	WANDERING,
	ATTACK,
	ATTACKING,
	DIE,
	DEAD
}

onready var BATTERY = preload("res://battery/Battery.tscn")
onready var KEY = preload("res://key/Key.tscn")

var ATTACK_ANIMATIONS = ['attack_front_left', 'attack_front_right', 'attack_back_left', 'attack_back_right']

var SPEED
var DAMAGE = 10
var DISTANCE_TO_ATTACK = 40
var DISTANCE_TO_NOTICE = 250
var DISTANCE_TO_LOOSE = 400
var DROP_BATTERY = true
var ANIMATION_PLAYER

var rng = RandomNumberGenerator.new()
var player_node
var map_node
var _last_velocity = Vector2(1, 0)
var _state = IDLE
var _life = 50
var _next_wandering_position
var _battery_drop_position
var key = false
var _boss

func set_distance_to_notice(new_distance):
	DISTANCE_TO_NOTICE = new_distance

func check_player():
	if self.global_position.distance_to(player_node.global_position) < DISTANCE_TO_NOTICE:
		_state = CHASE
		return true
	return false
	
func check_wandering():
	if rng.randf() < 0.7:
		_next_wandering_position = map_node.get_random_position()
		_state = WANDERING
	else:
		$DoNothingTimer.start(rng.randf_range(2.0, 10.0))

func update_velocity(direction, delta):
	var velocity = direction.normalized() * SPEED * delta
	if (velocity.x != 0 or velocity.y != 0):
		_last_velocity = velocity
	return velocity

func wander(delta, velocity):
	if self.global_position.distance_to(_next_wandering_position) < 50:
		_state = IDLE
	else:
		var direction = _next_wandering_position - self.global_position
		velocity = update_velocity(direction, delta)
	return velocity

func chase(delta, velocity):
	if self.global_position.distance_to(player_node.global_position) >= DISTANCE_TO_LOOSE:
		_state = LOST
	else:
		var direction = player_node.global_position - self.global_position
		if (direction.length() > DISTANCE_TO_ATTACK):
			velocity = update_velocity(direction, delta)
		else:
			_state = ATTACK
	return velocity

func attack():
	var direction = self.global_position.direction_to(player_node.global_position)
	if direction.x < 0:
		if direction.y < 0:
			ANIMATION_PLAYER.play("attack_back_left")
		else:
			ANIMATION_PLAYER.play("attack_front_left")
	else:
		if direction.y < 0:
			ANIMATION_PLAYER.play("attack_back_right")
		else:
			ANIMATION_PLAYER.play("attack_front_right")
	_state = ATTACKING

func drop_battery():
	if rng.randf() < 0.2:
		var battery = BATTERY.instance()
		battery.global_position = _battery_drop_position
		get_node('../').call_deferred('add_child', battery)

func drop_key():
	var new_key = KEY.instance()
	new_key.setup('steel')
	new_key.global_position = _battery_drop_position
	get_node('../').call_deferred('add_child', new_key)

func die():
	if _boss:
		_boss.notify_death()
	_battery_drop_position = self.global_position
	player_node.one_liner()
	self.visible = false
	ANIMATION_PLAYER.stop()
	$WallCollision.set_deferred('disabled', true)
	$HitBox/CollisionShape2D.set_deferred('disabled', true)
	$HurtEast/CollisionShape2D.set_deferred('disabled', true)
	$HurtWest/CollisionShape2D.set_deferred('disabled', true)
	if not key and DROP_BATTERY:
		drop_battery()
	elif key:
		drop_key()
	set_physics_process(false)
	_state = DEAD

func handle_state(delta):
	var velocity = Vector2()
	match _state:
		IDLE:
			if not check_player():
				if $DoNothingTimer.is_stopped():
					check_wandering()
		CHASE:
			velocity = chase(delta, velocity)
		LOST:
			ANIMATION_PLAYER.play('lost')
		WANDERING:
			if not check_player():
				velocity = wander(delta, velocity)
		ATTACK:
			attack()
		DIE:
			die()
	return velocity

func animate_run(direction):
	if direction.x < 0:
		if direction.y < 0:
			ANIMATION_PLAYER.play("run_back_left")
		else:
			ANIMATION_PLAYER.play("run_front_left")
	else:
		if direction.y < 0:
			ANIMATION_PLAYER.play("run_back_right")
		else:
			ANIMATION_PLAYER.play("run_front_right")

func animate():
	match _state:
		IDLE:
			if _last_velocity.x < 0:
				if _last_velocity.y < 0:
					ANIMATION_PLAYER.play("idle_back_left")
				else:
					ANIMATION_PLAYER.play("idle_front_left")
			else:
				if _last_velocity.y < 0:
					ANIMATION_PLAYER.play("idle_back_right")
				else:
					ANIMATION_PLAYER.play("idle_front_right")
		CHASE:
			var direction = self.global_position.direction_to(player_node.global_position)
			animate_run(direction)
		WANDERING:
			var direction = self.global_position.direction_to(_next_wandering_position)
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
	var collision = move_and_collide(velocity)
	if (collision):
		if _state == WANDERING:
			_state = IDLE

func _on_AnimationPlayer_animation_finished(anim_name):
	if (_state != DIE and _state != DEAD):
		if ATTACK_ANIMATIONS.has(anim_name):
			_state = IDLE
		elif anim_name == 'lost':
			_state = IDLE

func _on_area_shape_entered(_area_id, area, _area_shape, _self_shape):
	if area.is_in_group('hitbox'):
		var body = area.get_parent()
		if self.get_instance_id() != body.get_instance_id():
			body.hit(DAMAGE, _last_velocity)

func set_boss_reference(boss):
	_boss = boss

func hit(damage, _direction):
	_life -= damage
	if (_life > 0):
		$Hurt.play()
	else:
		$Dead.play()
		_state = DIE

func define_constants():
	SPEED = 100 * rng.randf_range(0.9, 1.2)
	ANIMATION_PLAYER = $Sprite/BaseAnimationPlayer

func _ready():
	map_node = get_node('../../')
	player_node = get_node("../42")
	rng.randomize()
	define_constants()
