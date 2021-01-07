extends KinematicBody2D

"""
Phase 1: evoke n skeletons and immortal until they all die, attack if 42 too close
Phase 2: like phase 1 + pentagrams
Phase 3: like phase 2 + crosses (any direction, they go straight to 42)
"""
onready var spawn_circle = preload("res://necromancer/SpawnCircle.tscn")
onready var PENTAGRAM = preload("res://boss_karate/Pentagram.tscn")
onready var CROW = preload("res://crow/Crow.tscn")
onready var CROSS = preload("res://boss_cop/CopCross.tscn")

const ATTACK_ANIMATIONS = [
	"attack_left", "attack_right"
]

const EVOKE_ANIMATIONS = [
	"evoke_left", "evoke_right"
]

const PENTAGRAM_ANIMATIONS = [
	"pentagram_left", "pentagram_right"
]

const CROSS_ANIMATIONS = [
	"cross_left", "cross_right"
]

enum {
	P1_IDLE,
	P1_ATTACK,
	P1_ATTACKING,
	P1_MOVE,
	P1_MOVING,
	P1_EVOKE,
	P1_NEXT_EVOKE,
	P1_EVOKING,
	P1_EVOKED,
	P2_IDLE,
	P2_ATTACK,
	P2_ATTACKING,
	P2_MOVE,
	P2_MOVING,
	P2_EVOKE,
	P2_NEXT_EVOKE,
	P2_EVOKING,
	P2_EVOKED,
	P2_PENTAGRAM,
	P2_CASTING,
	P2_CASTED,
	P2_CROWS,
	P3_IDLE,
	P3_ATTACK,
	P3_ATTACKING,
	P3_MOVE,
	P3_MOVING,
	P3_EVOKE,
	P3_NEXT_EVOKE,
	P3_EVOKING,
	P3_EVOKED,
	P3_PENTAGRAM,
	P3_CASTING,
	P3_CASTED,
	P3_CROWS,
	P3_CROSS,
	P3_CASTING_CROSS,
	DIE,
	DEAD
}

const MOVING_STATES = [P1_MOVING, P2_MOVING, P3_MOVING]

var PHASE_2_LIMIT = 200
var PHASE_3_LIMIT = 100
var DISTANCE_TO_NOTICE = 400
var DISTANCE_TO_ATTACK = 60
var DAMAGE = 30
var SKELETON_RANGE = [1, 3]
var MAX_CELL_X = 15
var MAX_CELL_Y = 7

var rng = RandomNumberGenerator.new()
var player_node
var _state = P1_IDLE
var _life = 300
var _phase = 1
var _pentagrams = []
var _invulnerable = false
var _number_of_skeletons = 0
var _skeletons_to_evoke = 0
var _can_evoke = true
var _can_move = true

func check_player(attack_state, other_state):
	var distance = self.global_position.distance_to(player_node.global_position)
	if player_node.global_position.x >= self.global_position.x and distance <= DISTANCE_TO_ATTACK:
		_state = attack_state
	else:
		_state = other_state

func attack(next_state):
	var direction = self.global_position.direction_to(player_node.global_position)
	if direction.x > 0:
		$Sprite/AnimationPlayer.play("attack_right")
	else:
		$Sprite/AnimationPlayer.play("attack_left")
	_state = next_state

func move(next_state):
	$MoveLight.energy = 1
	$MoveLight.visible = true
	_state = next_state

func go_idle():
	match _phase:
		1:
			_state = P1_IDLE
		2:
			_state = P2_IDLE
		3: 
			_state = P3_IDLE

func keep_evoking():
	match _phase:
		1:
			_state = P1_NEXT_EVOKE
		2:
			_state = P2_NEXT_EVOKE
		3: 
			_state = P3_NEXT_EVOKE

func evoke_one_skeleton(next_state):
	var direction = self.global_position.direction_to(player_node.global_position)
	if direction.x > 0:
		$Sprite/AnimationPlayer.play("evoke_right")
	else:
		$Sprite/AnimationPlayer.play("evoke_left")
	_state = next_state

func evoke(next_state):
	_skeletons_to_evoke = rng.randi_range(SKELETON_RANGE[0], SKELETON_RANGE[1])
	_invulnerable = true
	$HitBox/CollisionShape2D.set_deferred('disabled', true)
	$Sprite.modulate.a = 0.5
	_can_evoke = false
	$EvokeTimeout.start(rng.randf_range(10.0, 20.0))
	_state = next_state
	$Laugh1.play()

func spawn_skeleton():
	var pos_x = rng.randi_range(64, 64 * MAX_CELL_X)
	var pos_y = rng.randi_range(64, 64 * MAX_CELL_Y)
	var new_circle = spawn_circle.instance()
	new_circle.global_position = Vector2(pos_x, pos_y)
	new_circle.set_boss_reference(self)
	get_node('../').call_deferred('add_child', new_circle)
	_skeletons_to_evoke -= 1
	_number_of_skeletons += 1

func notify_death():
	_number_of_skeletons -= 1
	if _number_of_skeletons <= 0:
		_invulnerable = false
		$HitBox/CollisionShape2D.set_deferred('disabled', false)
		$Sprite.modulate.a = 1

func teleport():
	_can_move = false
	var new_position = self.global_position
	while new_position.distance_to(self.global_position) < 500:
		var pos_x = rng.randi_range(64, 64 * MAX_CELL_X)
		var pos_y = rng.randi_range(64, 64 * MAX_CELL_Y)
		new_position = Vector2(pos_x, pos_y)
	self.global_position = new_position
	$Teleport.play()
	$MoveTimeout.start(rng.randf_range(8, 15))
	go_idle()

func summon_pentagram():
	$Laugh2.play()
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

func cast_pentagram(next_state):
	var direction = self.global_position.direction_to(player_node.global_position)
	if direction.x < 0:
		$Sprite/AnimationPlayer.play("pentagram_left")
	else:
		$Sprite/AnimationPlayer.play("pentagram_right")
	_state = next_state

func shoot_cross():
	$Laugh3.play()
	var direction = self.global_position.direction_to(player_node.global_position)
	var position = self.global_position + (direction * 100)
	var new_cross = CROSS.instance()
	new_cross.setup(15, direction, position)
	get_node('../').call_deferred('add_child', new_cross)

func cast_cross(next_state):
	var direction = self.global_position.direction_to(player_node.global_position)
	if direction.x < 0:
		$Sprite/AnimationPlayer.play("cross_left")
	else:
		$Sprite/AnimationPlayer.play("cross_right")
	_state = next_state

func remove_pentagrams():
	while len(_pentagrams) > 0:
		_pentagrams.pop_front().queue_free()

func die():
	$Sprite.modulate.a = 1
	$Sprite/AnimationPlayer.play('die')
	$WallCollision.set_deferred('disabled', true)
	$HitBox/CollisionShape2D.set_deferred('disabled', true)
	$HurtBox/CollisionShape2D.set_deferred('disabled', true)
	$EvokeTimeout.stop()
	$MoveTimeout.stop()
	$CrowTimer.stop()
	$PentagramTimer.stop()
	$MoveLight.set_deferred('visible', true)
	remove_pentagrams()
	
func handle_state():
	match _state:
		P1_IDLE:
			var rand = rng.randf()
			if rand < 0.5:
				if _can_evoke:
					check_player(P1_ATTACK, P1_EVOKE)
				else:
					check_player(P1_ATTACK, P1_IDLE)
			else:
				if _can_move:
					check_player(P1_ATTACK, P1_MOVE)
				else:
					check_player(P1_ATTACK, P1_IDLE)
		P1_ATTACK:
			attack(P1_ATTACKING)
		P1_MOVE:
			move(P1_MOVING)
		P1_EVOKE:
			evoke(P1_NEXT_EVOKE)
		P1_NEXT_EVOKE:
			evoke_one_skeleton(P1_EVOKING)
		P2_IDLE:
			var rand = rng.randf()
			if rand < 0.5:
				if _can_evoke:
					check_player(P2_ATTACK, P2_EVOKE)
				else:
					check_player(P2_ATTACK, P2_IDLE)
			else:
				check_player(P2_ATTACK, P2_PENTAGRAM)
		P2_ATTACK:
			attack(P2_ATTACKING)
		P2_PENTAGRAM:
			cast_pentagram(P2_CASTING)
		P2_CASTED:
			$CrowTimer.start()
			_state = P2_CROWS
		P2_MOVE:
			move(P2_MOVING)
		P2_EVOKE:
			evoke(P2_NEXT_EVOKE)
		P2_NEXT_EVOKE:
			evoke_one_skeleton(P2_EVOKING)
		P3_IDLE:
			var rand = rng.randf()
			if rand < 0.3:
				if _can_evoke:
					check_player(P3_ATTACK, P3_EVOKE)
				else:
					check_player(P3_ATTACK, P3_IDLE)
			elif rand < 0.6:
				check_player(P3_ATTACK, P3_PENTAGRAM)
			else:
				check_player(P3_ATTACK, P3_CROSS)
		P3_ATTACK:
			attack(P3_ATTACKING)
		P3_PENTAGRAM:
			cast_pentagram(P3_CASTING)
		P3_CASTED:
			$CrowTimer.start()
			_state = P3_CROWS
		P3_CROSS:
			cast_cross(P3_CASTING_CROSS)
		P3_MOVE:
			move(P3_MOVING)
		P3_EVOKE:
			evoke(P3_NEXT_EVOKE)
		P3_NEXT_EVOKE:
			evoke_one_skeleton(P3_EVOKING)
		DIE:
			die()

func animate_idle():
	var direction = self.global_position.direction_to(player_node.global_position)
	if direction.x > 0:
		$Sprite/AnimationPlayer.play("idle_right")
	else:
		$Sprite/AnimationPlayer.play("idle_left")

func animate():
	match _state:
		P1_IDLE:
			animate_idle()
		P2_IDLE:
			animate_idle()
		P2_CASTED:
			animate_idle()
		P2_CROWS:
			animate_idle()
		P3_IDLE:
			animate_idle()
		P3_CASTED:
			animate_idle()
		P3_CROWS:
			animate_idle()

func handle_move_light(delta):
	if MOVING_STATES.has(_state):
		$MoveLight.energy -= delta
		if $MoveLight.energy <= 0:
			$MoveLight.set_deferred('visible', false)
			teleport()

func hit(damage, _direction):
	if not _invulnerable:
		_life -= damage
		if (_life > 0):
			$Hurt.play()
			if _phase == 2 and _life <= PHASE_3_LIMIT:
				_phase = 3
				go_idle()
			elif _phase == 1 and _life <= PHASE_2_LIMIT:
				_phase = 2
				go_idle()
		else:
			$Dead.play()
			_state = DIE
	else:
		$Fail.play()

func _physics_process(delta):
	handle_state()
	handle_move_light(delta)
	animate()

func _ready():
	rng.randomize()
	player_node = get_node("../42")

func _on_HurtBox_area_shape_entered(_area_id, area, _area_shape, _self_shape):
	if area.is_in_group('hitbox'):
		var body = area.get_parent()
		if self.get_instance_id() != body.get_instance_id():
			var direction = self.global_position.direction_to(body.global_position)
			body.hit(DAMAGE, direction)

func _on_AnimationPlayer_animation_finished(anim_name):
	if (_state != DIE and _state != DEAD):
		if ATTACK_ANIMATIONS.has(anim_name):
			go_idle()
		elif EVOKE_ANIMATIONS.has(anim_name):
			if _skeletons_to_evoke <= 0:
				go_idle()
			else:
				keep_evoking()
		elif PENTAGRAM_ANIMATIONS.has(anim_name):
			if _phase == 2:
				_state = P2_CASTED
			elif _phase == 3:
				_state = P3_CASTED
		elif CROSS_ANIMATIONS.has(anim_name):
			go_idle()
	else:
		if anim_name == 'die':
			set_physics_process(false)
			_state = DEAD
			self.visible = false
			get_node('../../').boss_dead()

func _on_EvokeTimeout_timeout():
	_can_evoke = true

func _on_MoveTimeout_timeout():
	_can_move = true

func _on_PentagramTimer_timeout():
	remove_pentagrams()
	$CrowTimer.stop()
	go_idle()

func _on_CrowTimer_timeout():
	spawn_crow()
