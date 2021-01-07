extends StaticBody2D

var check_player_pos = false
var activated = false
var player_node

func _process(_delta):
	if (check_player_pos):
		if not activated and self.global_position.distance_to(player_node.global_position) <= 80:
			$CollisionPolygon2D.disabled = false
			$Light2D.enabled = true
			$Activate.play()
			activated = true

func _on_AnimationPlayer_animation_finished(_anim_name):
	check_player_pos = true

func _ready():
	player_node = get_node("../42")
	$Sprite/AnimationPlayer.play("spawn")
