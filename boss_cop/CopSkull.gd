extends Node2D

enum {
	FALLING,
	ON_GROUND,
	TIC_TOC,
	EXPLODE,
	EXPLODED,
	FLYING
}

var _state = FALLING
var _destination_y
var _destination
var _velocity = Vector2.DOWN
var SPEED = 250
var DAMAGE = 20
var FLIGHT_DISTANCE = 200

func fly(delta):
	if self.global_position.distance_to(_destination) > 2:
		var direction = self.global_position.direction_to(_destination)
		self.translate(direction * delta * SPEED)
	else:
		if _state == FLYING:
			self.scale = Vector2(2.5, 2.5)
		_state = ON_GROUND

func fall(delta):
	if abs(self.global_position.y - _destination_y) > 5:
		self.translate(_velocity * delta * SPEED)
	else:
		_state = ON_GROUND

func explode():
	$Sprite/AnimationPlayer.play('explode')

func rotate(delta):
	if _state == FALLING:
		self.rotation_degrees = (self.rotation_degrees + delta * 1500)
		if (self.rotation_degrees > 360.0):
			self.rotation_degrees -= 360.0

func handle_state(delta):
	match _state:
		FALLING:
			if _velocity.y < 1:
				_velocity.y += 0.05
			fall(delta)
		ON_GROUND:
			$ExplosionTimer.start(1.0)
			_state = TIC_TOC
		EXPLODE:
			self.rotation_degrees = 0
			explode()
			_state = EXPLODED
		FLYING:
			fly(delta)

func setup(position, destination_y, initial_velocity):
	self.global_position = position
	_velocity = initial_velocity
	_destination_y = destination_y

func _ready():
	$Sprite/AnimationPlayer.play('base')

func _process(delta):
	rotate(delta)
	handle_state(delta)

func _on_ExplosionTimer_timeout():
	_state = EXPLODE

func _on_HurtBox_area_shape_entered(_area_id, area, _area_shape, _self_shape):
	if area.is_in_group('hitbox') and not area.is_in_group('boss'):
		var body = area.get_parent()
		if self.get_instance_id() != body.get_instance_id():
			body.hit(DAMAGE, self.global_position.direction_to(body.global_position))

func _on_Explode_finished():
	queue_free()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'explode':
		$Sprite.visible = false

func hit(_damage, direction):
	_destination = self.global_position + (direction.normalized() * FLIGHT_DISTANCE)
	self.scale = Vector2(3.5, 3.5)
	_state = FLYING
