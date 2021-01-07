extends Node2D

var rng = RandomNumberGenerator.new()
onready var crow = preload("res://crow/Crow.tscn")
var CROW_SPAWN_TIMEOUT = [2, 5]

var ghosts = {}
var number_of_ghosts = 2

func gate_open():
	return "res://cutscenes/Cutscene_Boss_Karate.tscn"

func get_scene_path():
	return "res://map_puzzle_1_v2/puzzle_map_1.tscn"

func get_ground_type(_pos):
	return 'floor'

func handle_ghosts():
	var ghost_1 = $Objects/Ghost
	var ghost_2 = $Objects/Ghost2
	ghosts[ghost_1.get_instance_id()] = ghost_1
	ghosts[ghost_2.get_instance_id()] = ghost_2
	$Objects/GhostBones.set_id(ghost_1.get_instance_id())
	$Objects/GhostBones2.set_id(ghost_2.get_instance_id())

func remove_ghost(ghost_id):
	ghosts[ghost_id].queue_free()
	$KillGhost.play()
	number_of_ghosts -= 1
	if (number_of_ghosts <= 0):
		$RedFog.visible = false
		$HeartBeat.stop()
		$Objects/ExitGate.open()
	$UI.update_ghosts(number_of_ghosts)

func setup():
	handle_ghosts()
	$UI.update_ghosts(number_of_ghosts)
	$SpawnGhost.play()

func _ready():
	rng.randomize()
	setup()
	$HeartBeat.play()
	$CrowSpawn.start(rng.randi_range(CROW_SPAWN_TIMEOUT[0], CROW_SPAWN_TIMEOUT[1]))

func _on_CrowSpawn_timeout():
	var new_crow = crow.instance()
	new_crow.position = Vector2(0, 512)
	$Objects.call_deferred('add_child', new_crow)
	$CrowSpawn.start(rng.randi_range(CROW_SPAWN_TIMEOUT[0], CROW_SPAWN_TIMEOUT[1]))
