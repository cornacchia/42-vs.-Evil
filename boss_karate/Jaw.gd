extends Node2D

var SPEED = 300
var _y_destination
var _direction = Vector2.LEFT
var _deg_diff = 1

func setup(y_destination, flip):
	_y_destination = y_destination
	if flip:
		$Sprite.flip_h = true
		_direction = Vector2.RIGHT

func _process(delta):
	self.rotation_degrees = (self.rotation_degrees + delta * 1500)
	if (self.rotation_degrees > 360.0):
		self.rotation_degrees -= 360.0
	if abs(self.global_position.y - _y_destination) > 5:
		_direction += Vector2(0, _deg_diff * 3 * delta)
		self.translate(_direction * delta * SPEED)
	else:
		set_process(false)
