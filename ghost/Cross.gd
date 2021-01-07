extends KinematicBody2D

enum {
	FLY,
	HIT
}

# Global configuration
var speed = 300
var _velocity = Vector2()
var _state = FLY
var _damage = 10

func setup(damage, velocity, position, rotation):
	_damage = damage
	_velocity = velocity
	self.position = position
	self.rotation_degrees = rotation

func animate():
	pass

func _physics_process(delta):
	var velocity = _velocity * speed * delta
	var collision = move_and_collide(velocity)
	if (collision):
		queue_free()
	animate()

func _on_Area2D_area_shape_entered(_area_id, area, _area_shape, _self_shape):
	if area.is_in_group('hitbox'):
		var body = area.get_parent()
		body.hit(_damage, _velocity)
		queue_free()
