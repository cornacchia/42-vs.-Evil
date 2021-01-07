extends StaticBody2D

var _opened = false
export var next_scene = ""

func open():
	$Sprite/AnimationPlayer.play('open')

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'open':
		$Gate.set_deferred('disabled', true)
		$Exit.set_deferred('monitoring', true)

func _on_Area2D_area_shape_entered(_area_id, area, _area_shape, _self_shape):
	if area.is_in_group('player'):
		var player = area.get_parent()
		if player.has_key('steel') and not _opened:
			player.remove_key('steel')
			_opened = true
			$GateOpen.play()
			open()
			next_scene = get_node('../../').gate_open()

func _on_Exit_area_shape_entered(_area_id, area, _area_shape, _self_shape):
	if area.is_in_group('player'):
		var err = get_tree().change_scene(next_scene)
		if err != OK:
			print('Error changing scene')
