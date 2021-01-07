extends Node2D

# Global configuration
var speed = 300
var _velocity = Vector2()

func setup(velocity, position):
	_velocity = velocity
	self.position = position

func _physics_process(delta):
	self.rotation_degrees = (self.rotation_degrees + delta * 1500)
	if (self.rotation_degrees > 360.0):
		self.rotation_degrees -= 360.0
	var velocity = _velocity * speed * delta
	self.translate(velocity)
