extends KinematicBody2D

enum {
	SPAWN,
	FLY,
	HIT
}

# Global constants
var rng = RandomNumberGenerator.new()

# Global configuration
var speed = 400
var _velocity = Vector2()
var _state = SPAWN
var _damage = 10

func setup(damage, velocity, position):
	_damage = damage
	_velocity = velocity
	self.position = position
	self.rotation_degrees = rad2deg(velocity.angle())

func animate():
	match _state:
		FLY:
			$Sprite/AnimationPlayer.play("fly")

func _physics_process(delta):
	if _state != HIT:
		var velocity = _velocity * speed * delta
		var collision = move_and_collide(velocity)
		if (collision):
			queue_free()
		animate()

func _on_area_shape_entered(_area_id, area, _area_shape, _self_shape):
	if area.is_in_group('bounce'):
		_velocity = _velocity * -1
		_velocity = _velocity.rotated(deg2rad(rng.randi_range(-60, 60)))
		self.rotation_degrees = rad2deg(self._velocity.angle())
		$HitShield.play()
	elif area.is_in_group('hitbox'):
		var body = area.get_parent()
		body.hit(_damage, _velocity)
		_state = HIT
		$Sprite/AnimationPlayer.play("hit")
	if area.is_in_group('counter'):
		var body = area.get_parent()
		body.counter()

func _ready():
	rng.randomize()
	$Sprite/AnimationPlayer.play("spawn")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "spawn":
		_state = FLY
	elif anim_name == "hit":
		queue_free()
