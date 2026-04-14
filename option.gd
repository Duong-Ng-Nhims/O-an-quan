extends Node2D


func _on_btn_home_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
	pass # Replace with function body.


func _on_btn_ai_pressed() -> void:
	get_tree().change_scene_to_file("res://ai_level.tscn")
	pass # Replace with function body.


func _on_btn_player_pressed() -> void:
	get_tree().change_scene_to_file("res://playground.tscn")
	pass # Replace with function body.
