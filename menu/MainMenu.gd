extends Node2D

var rng = RandomNumberGenerator.new()
var _positions = [Vector2(512, -64), Vector2(-64, 320), Vector2(1088, 320), Vector2(512, 640)]

func load_level(scene):
	var err = get_tree().change_scene(scene)
	if err != OK:
		print('Error loading scene!')

func start_game():
	load_level("res://instructions/Instructions.tscn")

func show_credits():
	load_level("res://credits/Credits.tscn")

func set_it():
	TranslationServer.set_locale("it")
	$MenuUI/Gioca.set_deferred('visible', true)
	$MenuUI/Start.set_deferred('visible', false)
	$MenuUI/Crediti.set_deferred('visible', true)
	$MenuUI/Credits.set_deferred('visible', false)

func set_en():
	TranslationServer.set_locale("en")
	$MenuUI/Gioca.set_deferred('visible', false)
	$MenuUI/Start.set_deferred('visible', true)
	$MenuUI/Crediti.set_deferred('visible', false)
	$MenuUI/Credits.set_deferred('visible', true)

func handle_input():
	if Input.is_action_just_pressed('ui_debug_menu'):
		var err = get_tree().change_scene("res://menu/menu.tscn")
		if err != OK:
			print('Error changing scene')

#func _process(_delta):
	#handle_input()

func _ready():
	rng.randomize()
	$MainTitle.play()
	$MenuUI/LangEN.grab_focus()
	$Rain.start()
	$Lightning.start()
	$Move42.start(rng.randf_range(2.0, 5.0))

func _on_Move42_timeout():
	var idx = rng.randi_range(0, 3)
	get_node('Objects/42').global_position = _positions[idx]
	$Move42.start(rng.randf_range(2.0, 5.0))
