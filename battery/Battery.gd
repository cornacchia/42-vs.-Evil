extends StaticBody2D

var PICKED = false

func pick_up(player):
	if not PICKED:
		PICKED = true
		$Sprite.visible = false
		$CollisionShape2D.set_deferred('disabled', true)
		$PickupSound.play()
		player.battery_power()

func _on_PickupSound_finished():
	queue_free()

func _ready():
	$Sprite/AnimationPlayer.play('idle')
