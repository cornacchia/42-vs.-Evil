extends Camera2D

enum {
	STATIC,
	MOVING,
	ZOOMING
}

var SPEED = 150
var ZOOM_SPEED = 400
var _state = STATIC
var _next_destination = Vector2(0, 0)
var _next_zoom = Vector2(1, 1)

func set_position_zoom(position, zoom):
	_next_destination = position
	_next_zoom = zoom
	_state = ZOOMING

func set_moving(new_destination):
	_next_destination = new_destination
	_state = MOVING

func move(delta):
	if self.global_position.distance_to(_next_destination) > 5:
		var direction = self.global_position.direction_to(_next_destination)
		self.translate(direction * delta * SPEED)
	else:
		_state = STATIC

func zoom(delta):
	var position_OK = false
	var zoom_OK = false
	if self.global_position.distance_to(_next_destination) > 5:
		var direction = self.global_position.direction_to(_next_destination)
		self.translate(direction * delta * ZOOM_SPEED)
	else:
		position_OK = true
	if self.zoom.x > _next_zoom.x:
		self.zoom.x -= delta
		self.zoom.y -= delta
	else:
		zoom_OK = true
	if position_OK and zoom_OK:
		_state = STATIC

func _process(delta):
	match _state:
		MOVING:
			move(delta)
		ZOOMING:
			zoom(delta)
