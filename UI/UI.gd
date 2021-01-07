extends CanvasLayer

var is_player_dead = false

func update_life(new_life):
	$Health.frame_coords = Vector2(0, 10 - floor(new_life / 10))

func update_blasphemy(new_blasphemy):
	$Blasphemy.frame_coords = Vector2(1, floor(new_blasphemy / 20))

func update_ghosts(number_of_ghosts):
	if number_of_ghosts > 0:
		$GhostLabel.text = str(number_of_ghosts)
	else:
		$GhostLabel.text = ""

func update_keys(keys):
	if keys['steel']:
		$SteelKey.visible = true
	if keys['gold']:
		$GoldKey.visible = true

func handle_input():
	if not is_player_dead and Input.is_action_just_pressed('ui_cancel'):
		get_tree().paused = not get_tree().paused
		if get_tree().paused:
			$PausedLabel.set_deferred('visible', true)
			$BackToMenu.set_deferred('visible', true)
			$RestartLevel.set_deferred('visible', true)
		else:
			$PausedLabel.set_deferred('visible', false)
			$BackToMenu.set_deferred('visible', false)
			$RestartLevel.set_deferred('visible', false)
	elif not is_player_dead and get_tree().paused and Input.is_action_just_pressed("ui_hide"):
		$PausedLabel.set_deferred('visible', not $PausedLabel.visible)
		$BackToMenu.set_deferred('visible', not $BackToMenu.visible)
		$RestartLevel.set_deferred('visible', not $RestartLevel.visible)

func _process(_delta):
	handle_input()

func _ready():
	get_node('42_Head/AnimationPlayer').play('smoke')

func _on_BackToMenu_pressed():
	get_tree().paused = false
	var scene = "res://menu/MainMenu.tscn"
	var err = get_tree().change_scene(scene)
	if err != OK:
		print('Error loading scene!')

func _on_RestartLevel_pressed():
	get_tree().paused = false
	var scene = get_node('../').get_scene_path()
	var err = get_tree().change_scene(scene)
	if err != OK:
		print('Error reloading scene!')

func player_dead():
	is_player_dead = true
	get_tree().paused = true
	$DeadLabel.set_deferred('visible', true)
	$BackToMenu.set_deferred('visible', true)
	$RestartLevel.set_deferred('visible', true)
