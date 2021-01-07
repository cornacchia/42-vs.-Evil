extends KinematicBody2D

# Global configuration
var speed = 300
var _velocity = Vector2()
var _damage = 10
var spriteRed = Vector2(8, 18)
var spriteRedYOffset = -15

func setup(damage, velocity, position, color):
	_damage = damage
	_velocity = velocity
	self.position = position
	if color == 'red':
		$Sprite.frame_coords = spriteRed
		$Sprite.offset.y = spriteRedYOffset

func _physics_process(delta):
	var velocity = _velocity * speed * delta
	var collision = move_and_collide(velocity)
	if (collision):
		queue_free()

func _on_Area2D_area_shape_entered(_area_id, area, _area_shape, _self_shape):
	if area.is_in_group('hitbox') and not area.is_in_group('boss'):
		var body = area.get_parent()
		body.hit(_damage, _velocity)
		queue_free()
