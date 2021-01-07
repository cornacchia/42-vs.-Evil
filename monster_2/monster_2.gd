extends "res://monster_1/monster_1.gd"

func die():
	.die()
	$ShieldHitBox/Normal.set_deferred('disabled', true)
	$ShieldHitBox/Raise.set_deferred('disabled', true)
	$ShieldHitBox/Attack_1.set_deferred('disabled', true)
	$ShieldHitBox/Attack_2.set_deferred('disabled', true)
	$ShieldHitBox/Attack_3.set_deferred('disabled', true)

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
	if _state != ATTACKING and _state != DEAD:
		$ShieldHitBox/Normal.set_deferred('disabled', false)
		$ShieldHitBox/Raise.set_deferred('disabled', true)
		$ShieldHitBox/Attack_1.set_deferred('disabled', true)
		$ShieldHitBox/Attack_2.set_deferred('disabled', true)
		$ShieldHitBox/Attack_3.set_deferred('disabled', true)

func _physics_process(_delta):
	reset_shield()

func define_constants():
	.define_constants()
	ANIMATION_PLAYER = $Sprite/ShieldAnimationPlayer
