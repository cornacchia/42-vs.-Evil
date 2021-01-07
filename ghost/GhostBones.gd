extends Node2D

onready var CROSS = preload("res://ghost/Cross.tscn")

var _id
var _life = 40
var frames
var _damage = 10

func shoot_crosses():
	var direction = Vector2.RIGHT
	rotation = deg2rad(45)
	for _i in range(8):
		direction = direction.rotated(rotation)
		var cross = CROSS.instance()
		var spawn_point = self.global_position + (direction * 64)
		cross.setup(_damage, direction, spawn_point, 270 + rad2deg(direction.angle()))
		get_node('../').call_deferred('add_child', cross)

func hit(damage, _velocity):
	$HitSound.play()
	_life -= damage
	shoot_crosses()
	if (_life <= 0):
		$Sprite.queue_free()
		$HitBox/CollisionShape2D.queue_free()
		$HitBox.queue_free()
		get_node('../../').remove_ghost(_id)
		queue_free()
	elif (_life <= 10):
		$Sprite.frame_coords.x = frames[2][0]
		$Sprite.frame_coords.y = frames[2][1]
	elif (_life <= 20):
		$Sprite.frame_coords.x = frames[1][0]
		$Sprite.frame_coords.y = frames[1][1]
	elif (_life <= 30):
		$Sprite.frame_coords.x = frames[0][0]
		$Sprite.frame_coords.y = frames[0][1]

func setup():
	frames = [[1, 4], [2, 4], [3, 4]]

func set_id(new_id):
	_id = new_id

func _ready():
	setup()
