extends KinematicBody2D

const SHOOT_ANIMATIONS = [
	"shoot_front_right", "shoot_down_right", "shoot_back_right", "shoot_up_right",
	"shoot_front_left", "shoot_down_left", "shoot_back_left", "shoot_up_left"
]

enum {
	IDLE,
	WALK,
	SHOOT,
	HIT,
	DEAD
}

# Global constants
var SHOOT_COOLDOWN = 10
var SPEED = 300
var ONE_LINER_PROBABILITY = 0.3
var rng = RandomNumberGenerator.new()

var ONE_LINERS = []
var one_liners_number = 13

# References
var UI

# Global variables
var _state = IDLE
var _last_velocity = Vector2(1, 0)
var _orientation = Vector2.RIGHT
var _shoot_cooldown = 0
var _life = 100
var _blasphemy = 0
var _damage = 8
var MAP_NODE
var _light_energy = 1.0
var keys = {
	'steel': false,
	'gold': false
}
export var REDUCE_LIGHT = true
export var BLASPHEMY_LIMIT = 100
export var immortal = false

onready var BULLET = preload("res://bullet/bullet.tscn")

func battery_power():
	_light_energy = 1.0

func set_drunkenness(drunkenness):
	$Camera2D._drunkenness += drunkenness

func remove_key(type):
	keys[type] = false
	UI.update_keys(keys)

func give_key(type):
	keys[type] = true
	UI.update_keys(keys)

func has_key(type):
	return keys[type]

func drink_bottle():
	if _life < 100:
		_life += 10
	set_drunkenness(20)
	UI.update_life(_life)
	if $Camera2D._drunkenness >= 250:
		die(true)

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

func animate_shoot():
	if _orientation.x > 0:
		if _orientation.y > 0:
			if _last_velocity.x > 0:
				$Sprite/AnimationPlayer.play("shoot_front_right")
			else:
				$Sprite/AnimationPlayer.play("shoot_down_right")
		else:
			if _last_velocity.x > 0:
				$Sprite/AnimationPlayer.play("shoot_back_right")
			else:
				$Sprite/AnimationPlayer.play("shoot_up_right")
	else:
		if _orientation.y > 0:
			if _last_velocity.x < 0:
				$Sprite/AnimationPlayer.play("shoot_front_left")
			else:
				$Sprite/AnimationPlayer.play("shoot_down_left")
		else:
			if _last_velocity.x < 0:
				$Sprite/AnimationPlayer.play("shoot_back_left")
			else:
				$Sprite/AnimationPlayer.play("shoot_up_left")

func check_action():
	if Input.is_action_pressed('ui_shoot'):
		_state = SHOOT
		animate_shoot()
		return true
	return false

func check_movement(delta, velocity):
	if Input.is_action_pressed('ui_right'):
		_orientation.x = 1
		velocity.x += 1
	elif Input.is_action_pressed('ui_left'):
		_orientation.x = -1
		velocity.x -= 1
	if Input.is_action_pressed('ui_down'):
		_orientation.y = 1
		velocity.y += 1
	elif Input.is_action_pressed('ui_up'):
		_orientation.y = -1
		velocity.y -= 1
	if velocity.x == 0 and velocity.y == 0:
		_state = IDLE
	else:
		_state = WALK
		if (velocity.x != 0 or velocity.y != 0):
			_last_velocity = velocity
		velocity = velocity.normalized() * SPEED * delta
	return velocity

func check_cooldown():
	if _shoot_cooldown > 0:
		_shoot_cooldown -= 1
	else:
		_state = IDLE

func play_walk_sound():
	var feet_position = self.global_position + Vector2(0, 32)
	var ground_type = MAP_NODE.get_ground_type(feet_position)
	if ground_type == 'grass':
		if not $StepDirt.playing:
			$StepDirt.play()
	elif ground_type == 'floor':
		if not $StepFloor.playing:
			$StepFloor.play()

func handle_state(delta):
	var velocity = Vector2()
	match _state:
		IDLE:
			if not check_action():
				velocity = check_movement(delta, velocity)
		WALK:
			if not check_action():
				velocity = check_movement(delta, velocity)
			play_walk_sound()
		HIT:
			pass
		DEAD:
			pass
	return velocity

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
		HIT:
			pass
		DEAD:
			pass

func handle_light_energy(delta):
	if (_light_energy > 0.3):
		_light_energy -= (delta * 0.01)
		$Light2D.energy = _light_energy

func handle_sprite_offset():
	if ($Sprite.offset.x > 0 and _last_velocity.x < 0):
		$Sprite.offset = Vector2(-8, 0)
	elif ($Sprite.offset.x < 0 and _last_velocity.x >= 0):
		$Sprite.offset = Vector2(8, 0)

func _physics_process(delta):
	var velocity = handle_state(delta)
	handle_sprite_offset()
	animate()
	if REDUCE_LIGHT:
		handle_light_energy(delta)
	var collision = move_and_collide(velocity)
	if collision:
		if collision.collider.is_in_group('pickup'):
			collision.collider.pick_up(self)
		elif collision.collider.is_in_group('pentagram'):
			hit(10, self.global_position.direction_to(collision.collider.global_position))

func loadDrunkDream():
	var err = get_tree().change_scene("res://map_puzzle_3/CutsceneDrunk.tscn")
	if err != OK:
		print('Error changing scene')

func die(drunk):
	$Dead.play()
	_state = DEAD
	$Sprite/AnimationPlayer.stop()
	$HitBox/CollisionShape2D.set_deferred('disabled', true)
	if (drunk):
		$DrunkTimer.start()
	else:
		$DeadTimer.start()

func hit(damage, _velocity):
	if (_state != HIT):
		$Camera2D.shake(damage)
		if not immortal:
			_life -= damage
		UI.update_life(_life)
		if (_life > 0):
			$Hurt.play()
			_state = HIT
			$HitTimeout.start()
		else:
			die(false)

func shake_camera(amount):
	$StompTimeout.start()
	$Camera2D.shake(amount)

func one_liner():
	if rng.randf() < ONE_LINER_PROBABILITY:
		$OneLiner.text = ONE_LINERS[rng.randi_range(0, len(ONE_LINERS) - 1)]
		$OneLiner.visible = true
		$OneLiner/Timer.start()

func update_blasphemy(new_blasphemy):
	_blasphemy += new_blasphemy
	if _blasphemy >= BLASPHEMY_LIMIT:
		_blasphemy = 0
		MAP_NODE.spawn_ghost()
	UI.update_blasphemy(_blasphemy)

func load_one_liners():
	for i in range(1, one_liners_number + 1):
		var one_liner_name = 'ONE_LINER_' + str(i)
		ONE_LINERS.append(tr(one_liner_name))

func stop_reducing_light():
	REDUCE_LIGHT = false

func _ready():
	load_one_liners()
	UI = get_node("../../UI")
	MAP_NODE = get_parent().get_parent()
	rng.randomize()

func _on_HitTimeout_timeout():
	_state = IDLE
	$Camera2D.stop_shaking()

func _on_Timer_timeout():
	$OneLiner.visible = false

func _on_AnimationPlayer_animation_finished(anim_name):
	if SHOOT_ANIMATIONS.has(anim_name):
		_state = IDLE

func _on_DrunkTimer_timeout():
	loadDrunkDream()

func _on_StompTimeout_timeout():
	$Camera2D.stop_shaking()

func _on_DeadTimer_timeout():
	UI.player_dead()
