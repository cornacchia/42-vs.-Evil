extends "res://monster_1/monster_1.gd"

onready var AXE = preload("res://monster_3/Axe.tscn")

func chase(delta, velocity):
	if self.global_position.distance_to(player_node.global_position) >= DISTANCE_TO_LOOSE:
		_state = LOST
	else:
		var direction = player_node.global_position - self.global_position
		if (direction.length() > DISTANCE_TO_ATTACK):
			if (abs(direction.y) < 10):
				attack_throw_axe()
			else:
				velocity = update_velocity(direction, delta)
		else:
			_state = ATTACK
	return velocity

func attack_throw_axe():
	var direction = self.global_position.direction_to(player_node.global_position)
	if direction.x < 0:
		if direction.y < 0:
			ANIMATION_PLAYER.play("throw_axe_back_left")
		else:
			ANIMATION_PLAYER.play("throw_axe_front_left")
	else:
		if direction.y < 0:
			ANIMATION_PLAYER.play("throw_axe_back_right")
		else:
			ANIMATION_PLAYER.play("throw_axe_front_right")
	_state = ATTACKING

func throw_axe():
	var axe = AXE.instance()
	var direction = self.global_position.direction_to(player_node.global_position)
	if (direction.x < 0):
		axe.setup(DAMAGE, Vector2.LEFT, $ThrowLeft.global_position)
	else:
		axe.setup(DAMAGE, Vector2.RIGHT, $ThrowRight.global_position)
	get_node('../').call_deferred('add_child', axe)
	$Throw.play()

func define_constants():
	.define_constants()
	ANIMATION_PLAYER = $Sprite/AxeAnimationPlayer
	DAMAGE = 15
	ATTACK_ANIMATIONS = [
		'attack_front_left', 
		'attack_front_right', 
		'attack_back_left', 
		'attack_back_right',
		'throw_axe_back_left',
		'throw_axe_back_right',
		'throw_axe_front_left',
		'throw_axe_front_right'
	]
