extends StaticBody2D

var _opened = false
var next_scene

func _on_Area2D_area_shape_entered(_area_id, area, _area_shape, _self_shape):
	if area.is_in_group('player'):
		var player = area.get_parent()
		if player.has_key('gold') and not _opened:
			player.remove_key('gold')
			_opened = true
			$GateOpen.play()
			$Door/AnimationPlayer.play('open')
			$DoorCollision.disabled = true
			next_scene = get_node('../../').crypt_open()

func _on_Entrance_area_shape_entered(_area_id, area, _area_shape, _self_shape):
	if area.is_in_group('player'):
		var err = get_tree().change_scene(next_scene)
		if err != OK:
			print('Error changing scene')
