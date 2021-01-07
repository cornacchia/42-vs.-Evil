extends Node2D

onready var monster_1 = preload("res://monster_1/monster_1.tscn")
onready var monster_2 = preload("res://monster_2/monster_2.tscn")
onready var monster_3 = preload("res://monster_3/monster_3.tscn")
var monster_types = []
var _boss
var rng = RandomNumberGenerator.new()

func set_boss_reference(boss):
	_boss = boss

func spawn():
	var type = rng.randi_range(0, 2)
	var new_monster = monster_types[type].instance()
	new_monster.global_position = self.global_position + Vector2(0, -32)
	new_monster.set_boss_reference(_boss)
	new_monster.set_distance_to_notice(500)
	get_node('../').call_deferred('add_child', new_monster)

func _ready():
	monster_types = [monster_1, monster_2, monster_3]
	rng.randomize()
	$Sprite/AnimationPlayer.play('spawn')

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'spawn':
		queue_free()
