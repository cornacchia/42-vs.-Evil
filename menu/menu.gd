extends Node2D

func load_level(scene):
	var err = get_tree().change_scene(scene)
	if err != OK:
		print('Error loading scene!')

func _on_Mappa_1_pressed():
	load_level("res://map_1/map_1.tscn")

func _on_Boss_1_pressed():
	load_level("res://boss_karate/MapBossKarate.tscn")

func _on_Cutscene_1_pressed():
	load_level("res://cutscenes/Cutscene_Map_1.tscn")

func _on_Lang_IT_pressed():
	TranslationServer.set_locale("it")

func _on_Lang_EN_pressed():
	TranslationServer.set_locale("en")

func _on_Boss_2_pressed():
	load_level("res://boss_cop/MapBossCop.tscn")

func _on_Boss_3_pressed():
	load_level("res://necromancer/MapNecromancer.tscn")

func _on_Mappa_2_pressed():
	load_level("res://map_2/map_2.tscn")

func _on_Mappa_3_pressed():
	load_level("res://map_3/map_3.tscn")

func _on_Cutscene_2_pressed():
	load_level("res://cutscenes/Cutscene_Map_2.tscn")

func _on_Cutscene_3_pressed():
	load_level("res://cutscenes/Cutscene_Map_3.tscn")

func _on_Puzzle_4_pressed():
	load_level("res://map_puzzle_1_v2/puzzle_map_1.tscn")

func _on_Puzzle_5_pressed():
	load_level("res://map_puzzle_2_v2/puzzle_map_2.tscn")

func _on_Puzzle_6_pressed():
	load_level("res://map_puzzle_3_v2/puzzle_map_3.tscn")

func _on_Cutscene_4_pressed():
	load_level("res://cutscenes/Cutscene_Boss_Karate.tscn")

func _on_Cutscene_5_pressed():
	load_level("res://cutscenes/Cutscene_Boss_Cop.tscn")

func _on_Cutscene_6_pressed():
	load_level("res://cutscenes/Cutscene_Necromancer.tscn")

func _on_Cutscene_7_pressed():
	load_level("res://cutscenes/FinalCutscene.tscn")

func _on_Cutscene_8_pressed():
	load_level("res://instructions/Instructions.tscn")
