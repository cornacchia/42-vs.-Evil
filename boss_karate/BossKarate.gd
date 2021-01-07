extends KinematicBody2D

# Phase1: normal run and attack
# Phase2: attack spawns a blade
# Phase3: no movement, attack spawns a blade, pentagrams

var ATTACK_ANIMATIONS = [
	'attack_front_left', 'attack_front_right', 'attack_back_left', 'attack_back_right',
	'attack_front_left_2', 'attack_front_right_2', 'attack_back_left_2', 'attack_back_right_2',
	'attack_front_left_3', 'attack_front_right_3', 'attack_back_left_3', 'attack_back_right_3',
	
]

var PENTAGRAM_ANIMATIONS = [
	'pentagram_front_left', 'pentagram_front_right', 'pentagram_back_left', 'pentagram_back_right'
]

var FALL_ANIMATIONS = [
	'fall_front_left', 'fall_front_right', 'fall_back_left', 'fall_back_right'
]

onready var WAVE = preload("res://boss_karate/Wave.tscn")
onready var PENTAGRAM = preload("res://boss_karate/Pentagram.tscn")
onready var CROW = preload("res://crow/Crow.tscn")
onready var JAW = preload("res://boss_karate/Jaw.tscn")

enum {
	P1_IDLE,
	P1_CHASE,
	P1_ATTACK,
	P1_ATTACKING,
	P2_IDLE,
	P2_CHASE,
	P2_ATTACK,
	P2_ATTACKING,
	FALLING,
	P3_IDLE,
	P3_ATTACK,
	P3_ATTACKING,
	P3_PENTAGRAM,
	P3_CASTING,
	P3_CASTED,
	P3_CROWS,
	DIE,
	DEAD
}

var PHASE_2_LIMIT = 200
var PHASE_3_LIMIT = 100
var DISTANCE_TO_NOTICE = 400
var DISTANCE_TO_ATTACK = 60
var SPEED = 150
var DAMAGE = 20
var GROUND_SHAKE_AMOUNT = 10

var rng = RandomNumberGenerator.new()
var player_node
var _last_velocity = Vector2.LEFT
var _state = P1_IDLE
var _life = 300
var _phase = 1
var _pentagrams = []

func loose_jaw():
	var new_jaw = JAW.instance()
	new_jaw.global_position = $JawPosition.global_position
	var y_destination = self.global_position.y + 64
	var flip = false
	if _last_velocity.x < 0:
		flip = true
	new_jaw.setup(y_destination, flip)
	get_node('../').call_deferred('add_child', new_jaw)

func shake_ground():
	player_node.shake_camera(GROUND_SHAKE_AMOUNT)

func check_player(next_state):
	if self.global_position.distance_to(player_node.global_position) < DISTANCE_TO_NOTICE:
		_state = next_state

func check_player_3():
	if self.global_position.distance_to(player_node.global_position) < DISTANCE_TO_NOTICE:
		if abs(self.global_position.y - player_node.global_position.y) < 100 or abs(self.global_position.x - player_node.global_position.x) < 100:
			_state = P3_ATTACK
		else:
			_state = P3_PENTAGRAM
	else:
		_state = P3_PENTAGRAM

func update_velocity(direction, delta):
	var velocity = direction.normalized() * SPEED * delta
	if (velocity.x != 0 or velocity.y != 0):
		_last_velocity = velocity
	return velocity

func chase(delta, velocity, next_state):
	var direction = player_node.global_position - self.global_position
	match _state:
		P1_CHASE:
			if (direction.length() > DISTANCE_TO_ATTACK):
				velocity = update_velocity(direction, delta)
			else:
				_state = next_state
		P2_CHASE:
			if (direction.length() <= DISTANCE_TO_ATTACK or abs(self.global_position.y - player_node.global_position.y) < 70):
				_state = next_state
			else:
				velocity = update_velocity(direction, delta)
	return velocity

func spawn_wave(direction):
	var wave = WAVE.instance()
	var color = 'white'
	var damage = 20
	if _phase > 2:
		color = 'red'
		damage = 30
	var spawnPosition = $SpawnWaveEast.global_position
	if _phase > 2:
		spawnPosition += Vector2(0, 15)
	if (direction == Vector2.LEFT):
		wave.rotation_degrees = 180
		spawnPosition = $SpawnWaveWest.global_position
		if _phase > 2:
			spawnPosition += Vector2(0, 15)
	elif (direction == Vector2.UP):
		wave.rotation_degrees = 270
		spawnPosition = $SpawnWaveNorth.global_position
	elif (direction == Vector2.DOWN):
		wave.rotation_degrees = 90
		spawnPosition = $SpawnWaveSouth.global_position
	wave.setup(damage, direction, spawnPosition, color)
	get_node('../').call_deferred('add_child', wave)

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

func cast_pentagram():
	var direction = self.global_position.direction_to(player_node.global_position)
	if direction.x < 0:
		if direction.y < 0:
			$Sprite/BaseAnimationPlayer.play("pentagram_back_left")
		else:
			$Sprite/BaseAnimationPlayer.play("pentagram_front_left")
	else:
		if direction.y < 0:
			$Sprite/BaseAnimationPlayer.play("pentagram_back_right")
		else:
			$Sprite/BaseAnimationPlayer.play("pentagram_front_right")

func summon_pentagram():
	var new_pentagram = PENTAGRAM.instance()
	new_pentagram.global_position = player_node.global_position
	get_node('../').call_deferred('add_child', new_pentagram)
	_pentagrams.push_front(new_pentagram)
	$PentagramTimer.start(5)

func spawn_crow():
	var new_crow = CROW.instance()
	var x_offset = rng.randi_range(300, 500)
	if rng.randf() < 0.5:
		x_offset *= -1
	var y_offset = rng.randi_range(0, 300)
	if rng.randf() < 0.5:
		y_offset *= -1
	new_crow.global_position = player_node.global_position + Vector2(x_offset, y_offset)
	get_node('../').call_deferred('add_child', new_crow)

func remove_pentagrams():
	while len(_pentagrams) > 0:
		_pentagrams.pop_front().queue_free()

func die():
	$Sprite/BaseAnimationPlayer.play('die')
	$WallCollision.set_deferred('disabled', true)
	$HitBox/CollisionDown.set_deferred('disabled', true)
	$HitBox/CollisionShape2D.set_deferred('disabled', true)
	$HurtEast/CollisionDown.set_deferred('disabled', true)
	$HurtEast/CollisionShape2D.set_deferred('disabled', true)
	$HurtWest/CollisionDown.set_deferred('disabled', true)
	$HurtWest/CollisionShape2D.set_deferred('disabled', true)
	remove_pentagrams()

func handle_state(delta):
	var velocity = Vector2()
	match _state:
		P1_IDLE:
			#check_player(P1_CHASE)
			_state = P1_CHASE
		P1_CHASE:
			velocity = chase(delta, velocity, P1_ATTACK)
		P2_IDLE:
			check_player(P2_CHASE)
		P2_CHASE:
			velocity = chase(delta, velocity, P2_ATTACK)
		P3_IDLE:
			check_player_3()
		P1_ATTACK:
			attack(P1_ATTACKING, "")
		P2_ATTACK:
			attack(P2_ATTACKING, "_2")
		P3_ATTACK:
			attack(P3_ATTACKING, "_3")
		P3_PENTAGRAM:
			cast_pentagram()
		P3_CASTED:
			$CrowTimer.start()
			_state = P3_CROWS
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

func fall_down():
	$HitBox/CollisionShape2D.set_deferred('disabled', true)
	$HitBox/CollisionDown.set_deferred('disabled', false)
	var direction = self.global_position.direction_to(player_node.global_position)
	if direction.x < 0:
		if direction.y < 0:
			$Sprite/BaseAnimationPlayer.play("fall_back_left")
		else:
			$Sprite/BaseAnimationPlayer.play("fall_front_left")
	else:
		if direction.y < 0:
			$Sprite/BaseAnimationPlayer.play("fall_back_right")
		else:
			$Sprite/BaseAnimationPlayer.play("fall_front_right")

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
		P3_CASTED:
			animate_idle(_last_velocity, "_3")
		P3_CROWS:
			animate_idle(_last_velocity, "_3")

func _physics_process(delta):
	var velocity = handle_state(delta)
	animate()
	var _collision = move_and_collide(velocity)

func _ready():
	rng.randomize()
	player_node = get_node("../42")

func go_idle():
	if _phase == 1:
		_state = P1_IDLE
	elif _phase == 2:
		_state = P2_IDLE
	elif _phase == 3:
		_state = P3_IDLE

func _on_BaseAnimationPlayer_animation_finished(anim_name):
	if (_state != DIE and _state != DEAD):
		if ATTACK_ANIMATIONS.has(anim_name):
			go_idle()
		elif PENTAGRAM_ANIMATIONS.has(anim_name):
			_state = P3_CASTED
		elif FALL_ANIMATIONS.has(anim_name):
			go_idle()
	else:
		if anim_name == 'die':
			set_physics_process(false)
			_state = DEAD
			$Sprite.frame_coords = Vector2(3, 28)
			get_node('../../').boss_dead()

func _on_area_shape_entered(_area_id, area, _area_shape, _self_shape):
	if area.is_in_group('hitbox'):
		var body = area.get_parent()
		if self.get_instance_id() != body.get_instance_id():
			body.hit(DAMAGE, _last_velocity)

func hit(damage, _direction):
	_life -= damage
	if (_life > 0):
		$Hurt.play()
		if _phase == 2 and _life <= PHASE_3_LIMIT:
			fall_down()
			_state = FALLING
			_phase = 3
		elif _phase == 1 and _life <= PHASE_2_LIMIT:
			loose_jaw()
			_phase = 2
			go_idle()
	else:
		$Dead.play()
		_state = DIE


func _on_PentagramTimer_timeout():
	remove_pentagrams()
	$CrowTimer.stop()
	_state = P3_IDLE

func _on_CrowTimer_timeout():
	spawn_crow()
