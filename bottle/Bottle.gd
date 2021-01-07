extends StaticBody2D

var PICKED = false

func pick_up(player):
	if not PICKED:
		PICKED = true
		$Sprite.visible = false
		$CollisionShape2D.set_deferred('disabled', true)
		$DrinkSound.play()
		player.drink_bottle()

func _on_DrinkSound_finished():
	queue_free()

func _ready():
	$Sprite/AnimationPlayer.play('idle')
