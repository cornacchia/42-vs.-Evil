extends Camera2D

enum {
	SHAKE,
	DRUNK,
	NORMAL
}

var rng = RandomNumberGenerator.new()
var SHAKE_AMOUNT = 2.0

var _drunkenness = 0
var _drunk_cycle = 0
var _offset_x = 0.0
var _offset_y = 0.0
var _state = NORMAL
var _shaking = false

func shake_screen():
	self.set_offset(Vector2( \
		_offset_x + (rng.randi_range(-1.0, 1.0) * SHAKE_AMOUNT), \
		_offset_y + (rng.randi_range(-1.0, 1.0) * SHAKE_AMOUNT) \
	))

func drunk_screen(_delta):
	_drunk_cycle = (_drunk_cycle + 0.05)
	if (_drunk_cycle >= 2 * PI):
		_drunk_cycle = 0.0
	_offset_x = sin(_drunk_cycle) * _drunkenness
	_offset_y = cos(_drunk_cycle) * _drunkenness
	self.set_offset(Vector2( \
		_offset_x, \
		_offset_y \
	))
	if _shaking:
		shake_screen()

func shake(damage):
	SHAKE_AMOUNT = damage / 10.0
	_shaking = true

func stop_shaking():
	_shaking = false

func _process(delta):
	match _state:
		NORMAL:
			if _drunkenness > 0:
				_state = DRUNK
			elif _shaking:
				shake_screen()
		DRUNK:
			drunk_screen(delta)

func _ready():
	rng.randomize()
