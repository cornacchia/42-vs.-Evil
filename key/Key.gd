extends StaticBody2D

var TYPE = 'steel'
var PICKED = false
var light_flicker = -1

func pick_up(player):
	if not PICKED:
		PICKED = true
		$Sprite.visible = false
		$CollisionShape2D.set_deferred('disabled', true)
		$Light2D.set_deferred('visible', false)
		$PickupSound.play()
		player.give_key(TYPE)

func _on_PickupSound_finished():
	queue_free()

func setup(type):
	TYPE = type
	if type == 'gold':
		$Light2D.color = Color(0.68, 0.68, 0, 1)
		$Sprite/AnimationPlayer.play("key_gold")
	else:
		$Light2D.color = Color(1, 1, 0.84, 1)
		$Sprite/AnimationPlayer.play("key_steel")

func _process(delta):
	$Light2D.energy += (delta * light_flicker)
	if $Light2D.energy <= 0 or $Light2D.energy > 1:
		light_flicker *= -1
