extends KinematicBody2D

var ATTACK_ANIMATIONS = [
	'attack_front_left', 'attack_front_right', 'attack_back_left', 'attack_back_right',
	'attack_front_left_2', 'attack_front_right_2', 'attack_back_left_2', 'attack_back_right_2',
	'attack_front_left_3', 'attack_front_right_3', 'attack_back_left_3', 'attack_back_right_3',
	
]

var THROWING_ANIMATIONS = [
	'throw_back_left_2', 'throw_front_left_2', 'throw_back_right_2', 'throw_front_right_2',
	'throw_back_left_3', 'throw_front_left_3', 'throw_back_right_3', 'throw_front_right_3'
]

onready var VISOR = preload("res://boss_cop/Visor.tscn")
onready var HELMET = preload("res://boss_cop/Helmet.tscn")
onready var SKULL = preload("res://boss_cop/CopSkull.tscn")
onready var CROSS = preload("res://boss_cop/CopCross.tscn")

enum {
	P1_IDLE,
	P1_CHASE,
	P1_ATTACK,
	P1_ATTACKING,
	P2_IDLE,
	P2_CHASE,
	P2_ATTACK,
	P2_ATTACKING,
	P2_THROW,
	P2_THROWING,
	P3_IDLE,
	P3_CHASE,
	P3_ATTACK,
	P3_ATTACKING,
	P3_THROW,
	P3_THROWING,
	DIE,
	DEAD
}

var PHASE_2_LIMIT = 200
var PHASE_3_LIMIT = 100
var DISTANCE_TO_NOTICE = 400
var DISTANCE_TO_ATTACK = 80
var SPEED = 180
var DAMAGE = 20
var GROUND_SHAKE_AMOUNT = 20

var rng = RandomNumberGenerator.new()
var player_node
var _last_velocity = Vector2.LEFT
var _state = P1_IDLE
var _life = 300
var _phase = 1
var _light = 0
var _light_sign = 1

func loose_visor_helmet():
	var new_obj
	if _phase == 1:
		new_obj = VISOR.instance()
	else:
		new_obj = HELMET.instance()
	new_obj.global_position = $HelmetPosition.global_position
	var y_destination = self.global_position.y + 96
	var flip = false
	if _last_velocity.x < 0:
		flip = true
	new_obj.setup(y_destination, flip)
	get_node('../').call_deferred('add_child', new_obj)

func shake_ground():
	player_node.shake_camera(GROUND_SHAKE_AMOUNT)

func check_player(next_state):
	if self.global_position.distance_to(player_node.global_position) < DISTANCE_TO_NOTICE:
		_state = next_state

func update_velocity(direction, delta):
	var velocity = direction.normalized() * SPEED * delta
	if (velocity.x != 0 or velocity.y != 0):
		_last_velocity = velocity
	return velocity

func chase(delta, velocity, next_state, alt_state):
	var direction = player_node.global_position - self.global_position
	match _state:
		P1_CHASE:
			if (direction.length() > DISTANCE_TO_ATTACK):
				velocity = update_velocity(direction, delta)
			else:
				_state = next_state
		P2_CHASE:
			if direction.length() <= DISTANCE_TO_ATTACK:
				_state = next_state
			elif abs(self.global_position.y - player_node.global_position.y) < 70:
				if rng.randf() < 0.3:
					_state = alt_state
				else:
					velocity = update_velocity(direction, delta)
			else:
				velocity = update_velocity(direction, delta)
		P3_CHASE:
			if direction.length() <= DISTANCE_TO_ATTACK:
				_state = next_state
			elif abs(self.global_position.y - player_node.global_position.y) < 70:
				if rng.randf() < 0.3:
					_state = alt_state
				else:
					velocity = update_velocity(direction, delta)
			else:
				velocity = update_velocity(direction, delta)
	return velocity

func start_throwing_skull(phase, next_state):
	var direction = self.global_position.direction_to(player_node.global_position)
	if direction.x < 0:
		if direction.y < 0:
			$Sprite/BaseAnimationPlayer.play("throw_back_left" + phase)
		else:
			$Sprite/BaseAnimationPlayer.play("throw_front_left" + phase)
	else:
		if direction.y < 0:
			$Sprite/BaseAnimationPlayer.play("throw_back_right" + phase)
		else:
			$Sprite/BaseAnimationPlayer.play("throw_front_right" + phase)
	_state = next_state

func throw_skull():
	var distance = self.global_position.distance_to(player_node.global_position)
	var base_velocity = distance * 0.005
	var new_skull = SKULL.instance()
	var direction = self.global_position.direction_to(player_node.global_position)
	var position = $ThrowEast.global_position
	var velocity = Vector2(base_velocity, -1)
	if direction.x < 0:
		position = $ThrowWest.global_position
		velocity = Vector2(base_velocity * -1, -1)
	new_skull.setup(position, player_node.global_position.y, velocity)
	get_node('../').call_deferred('add_child', new_skull)

func counter():
	if (_phase == 3):
		if _last_velocity.x > 0:
			shoot_cross(Vector2.RIGHT, $SpawnCrossEast.global_position)
		else:
			shoot_cross(Vector2.LEFT, $SpawnCrossWest.global_position)

func shoot_cross(direction, position):
	var new_cross = CROSS.instance()
	new_cross.setup(15, direction, position)
	get_node('../').call_deferred('add_child', new_cross)

func attack(next_state, phase):
	var direction = self.global_position.direction_to(player_node.global_position)
	if direction.x < 0:
		if direction.y < 0:
			$Sprite/BaseAnimationPlayer.play("attack_back_left" + phase)
		else:
			$Sprite/BaseAnimationPlayer.play("attack_front_left" + phase)
	else:
		if direction.y < 0:
			$Sprite/BaseAnimationPlayer.play("attack_back_right" + phase)
		else:
			$Sprite/BaseAnimationPlayer.play("attack_front_right" + phase)
	_state = next_state

func die():
	$Sprite/BaseAnimationPlayer.play('die')
	$WallCollision.set_deferred('disabled', true)
	$HitBox/CollisionShape2D.set_deferred('disabled', true)
	$HurtEast/CollisionShape2D.set_deferred('disabled', true)
	$HurtWest/CollisionShape2D.set_deferred('disabled', true)
	$ShieldHitBox/Attack_1.set_deferred('disabled', true)
	$ShieldHitBox/Attack_2.set_deferred('disabled', true)
	$ShieldHitBox/Attack_3.set_deferred('disabled', true)
	$ShieldHitBox/Normal.set_deferred('disabled', true)
	$ShieldHitBox/Raise.set_deferred('disabled', true)

func handle_state(delta):
	var velocity = Vector2()
	match _state:
		P1_IDLE:
			#check_player(P1_CHASE)
			_state = P1_CHASE
		P1_CHASE:
			velocity = chase(delta, velocity, P1_ATTACK, null)
		P2_IDLE:
			check_player(P2_CHASE)
		P2_CHASE:
			velocity = chase(delta, velocity, P2_ATTACK, P2_THROW)
		P3_IDLE:
			check_player(P3_CHASE)
		P3_CHASE:
			velocity = chase(delta, velocity, P3_ATTACK, P3_THROW)
		P1_ATTACK:
			attack(P1_ATTACKING, "")
		P2_ATTACK:
			attack(P2_ATTACKING, "_2")
		P3_ATTACK:
			attack(P3_ATTACKING, "_3")
		P2_THROW:
			start_throwing_skull("_2", P2_THROWING)
		P3_THROW:
			start_throwing_skull("_3", P3_THROWING)
		DIE:
			die()
	return velocity

func animate_idle(direction, phase):
	if direction.x < 0:
		if direction.y < 0:
			$Sprite/BaseAnimationPlayer.play("idle_back_left" + phase)
		else:
			$Sprite/BaseAnimationPlayer.play("idle_front_left" + phase)
	else:
		if direction.y < 0:
			$Sprite/BaseAnimationPlayer.play("idle_back_right" + phase)
		else:
			$Sprite/BaseAnimationPlayer.play("idle_front_right" + phase)

func animate_chase(direction, phase):
	if direction.x < 0:
		if direction.y < 0:
			$Sprite/BaseAnimationPlayer.play("run_back_left" + phase)
		else:
			$Sprite/BaseAnimationPlayer.play("run_front_left" + phase)
	else:
		if direction.y < 0:
			$Sprite/BaseAnimationPlayer.play("run_back_right" + phase)
		else:
			$Sprite/BaseAnimationPlayer.play("run_front_right" + phase)

func animate():
	match _state:
		P1_IDLE:
			animate_idle(_last_velocity, "")
		P2_IDLE:
			animate_idle(_last_velocity, "_2")
		P3_IDLE:
			animate_idle(self.global_position.direction_to(player_node.global_position), "_3")
		P1_CHASE:
			var direction = self.global_position.direction_to(player_node.global_position)
			animate_chase(direction, "")
		P2_CHASE:
			var direction = self.global_position.direction_to(player_node.global_position)
			animate_chase(direction, "_2")
		P3_CHASE:
			var direction = self.global_position.direction_to(player_node.global_position)
			animate_chase(direction, "_3")

func handle_sprite_offset():
	if ($Sprite.offset.x > 0 and _last_velocity.x < 0):
		$Sprite.offset = Vector2(-8, 0)
		if $ShieldHitBox.scale.x < 0:
			$ShieldHitBox.scale.x *= -1
	elif ($Sprite.offset.x < 0 and _last_velocity.x >= 0):
		$Sprite.offset = Vector2(8, 0)
		if $ShieldHitBox.scale.x > 0:
			$ShieldHitBox.scale.x *= -1

func reset_shield():
	if _state != P1_ATTACKING and _state != P2_ATTACKING and _state != P3_ATTACKING and _state != DIE and _state != DEAD:
		$ShieldHitBox/Normal.set_deferred('disabled', false)
		$ShieldHitBox/Raise.set_deferred('disabled', true)
		$ShieldHitBox/Attack_1.set_deferred('disabled', true)
		$ShieldHitBox/Attack_2.set_deferred('disabled', true)
		$ShieldHitBox/Attack_3.set_deferred('disabled', true)

func handle_lights(delta):
	if _light == 0:
		$RedLight.energy += delta * _light_sign
		if $RedLight.energy > 0.6:
			_light_sign = -1
		elif $RedLight.energy <= 0:
			_light_sign = 1
			_light = 1
	else:
		$BlueLight.energy += delta * _light_sign
		if $BlueLight.energy > 0.6:
			_light_sign = -1
		elif $BlueLight.energy <= 0:
			_light_sign = 1
			_light = 0

func _physics_process(delta):
	var velocity = handle_state(delta)
	handle_lights(delta)
	handle_sprite_offset()
	reset_shield()
	animate()
	var _collision = move_and_collide(velocity)

func go_idle():
	if _phase == 1:
		_state = P1_IDLE
	elif _phase == 2:
		_state = P2_IDLE
	elif _phase == 3:
		_state = P3_IDLE

func hit(damage, _direction):
	_life -= damage
	if (_life > 0):
		$Hurt.play()
		if _phase == 2 and _life <= PHASE_3_LIMIT:
			loose_visor_helmet()
			_phase = 3
			go_idle()
		elif _phase == 1 and _life <= PHASE_2_LIMIT:
			loose_visor_helmet()
			_phase = 2
			go_idle()
	else:
		$Dead.play()
		_state = DIE

func _ready():
	rng.randomize()
	player_node = get_node("../42")

func _on_BaseAnimationPlayer_animation_finished(anim_name):
	if (_state != DIE and _state != DEAD):
		if ATTACK_ANIMATIONS.has(anim_name):
			go_idle()
		elif THROWING_ANIMATIONS.has(anim_name):
			go_idle()
	else:
		if anim_name == 'die':
			set_physics_process(false)
			_state = DEAD
			$Sprite.frame_coords = Vector2(6, 32)
			get_node('../../').boss_dead()

func _on_area_shape_entered(_area_id, area, _area_shape, _self_shape):
	if area.is_in_group('hitbox'):
		var body = area.get_parent()
		if self.get_instance_id() != body.get_instance_id():
			body.hit(DAMAGE, _last_velocity)
