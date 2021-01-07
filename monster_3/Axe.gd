extends KinematicBody2D

# Global configuration
var speed = 300
var _velocity = Vector2()
var _damage = 15

func setup(damage, velocity, position):
	_damage = damage
	_velocity = velocity
	self.position = position

func _physics_process(delta):
	self.rotation_degrees = (self.rotation_degrees + delta * 1500)
	if (self.rotation_degrees > 360.0):
		self.rotation_degrees -= 360.0
	var velocity = _velocity * speed * delta
	var collision = move_and_collide(velocity)
	if (collision):
		queue_free()

func _on_Area2D_area_shape_entered(_area_id, area, _area_shape, _self_shape):
	if area.is_in_group('hitbox'):
		var body = area.get_parent()
		body.hit(_damage, _velocity)
		queue_free()
