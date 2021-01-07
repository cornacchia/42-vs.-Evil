extends StaticBody2D

onready var BOTTLE = preload("res://bottle/Bottle.tscn")
onready var KEY = preload("res://key/Key.tscn")

var rng = RandomNumberGenerator.new()
var _life = 60
var frames
var DROPPED = false
var options = {
	'special': false,
	'indoor': false
}
export var indoor_tomb = false

func drop_key():
	var key = KEY.instance()
	key.setup('gold')
	key.global_position = self.global_position
	get_node('../').call_deferred('add_child', key)

func drop_bottle():
	var bottle = BOTTLE.instance()
	bottle.position = self.global_position
	get_node('../').call_deferred('add_child', bottle)

func hit(damage, _velocity):
	$HitSound.play()
	_life -= damage
	if (_life <= 0):
		$Tomb.frame_coords.x = frames[2][0]
		$Tomb.frame_coords.y = frames[2][1]
		$Tomb.z_index = -1
		$HitBox/CollisionPolygon2D.queue_free()
		$HitBox.queue_free()
		$CollisionShape2D.queue_free()
		get_node('../42').update_blasphemy(20)
		if options['special']:
			if not DROPPED:
				DROPPED = true
				drop_key()
		else:
			if (not DROPPED and rng.randf() < 0.3):
				DROPPED = true
				drop_bottle()
	elif (_life <= 20):
		$Tomb.frame_coords.x = frames[1][0]
		$Tomb.frame_coords.y = frames[1][1]
	elif (_life <= 40):
		$Tomb.frame_coords.x = frames[0][0]
		$Tomb.frame_coords.y = frames[0][1]

func setup():
	if options['special']:
		$Tomb.frame_coords = Vector2(0, 5)
		frames = [[1, 5], [2, 5], [3, 5]]
	else:
		var rand = rng.randf()
		$Tomb.frame_coords = Vector2(0, 2)
		frames = [[1, 2], [2, 2], [3, 2]]
		if rng.randf() < 0.3:
			$Tomb.frame_coords = Vector2(0, 0)
			frames = [[1, 0], [2, 0], [3, 0]]
		elif rand < 0.6:
			$Tomb.frame_coords = Vector2(0, 4)
			frames = [[1, 4], [2, 4], [3, 4]]
	if options['indoor']:
		$Ground.frame_coords = Vector2(9, 1)
	else:
		$Ground.frame_coords = Vector2(9, 0)

func _ready():
	if indoor_tomb:
		options['indoor'] = true
	rng.randomize()
	setup()
