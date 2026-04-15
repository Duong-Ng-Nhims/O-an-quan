extends Node2D

 # Replace with function body.
func _ready() -> void:
	#Sounds.play_bgm("res://Sound/nhac.nen.man.hinh.chinh.mp3")
	Sounds.play_bgm1()
	print("play bgm called")
	

func _on_quit_btn_pressed() -> void:
	Sounds.Click_Sound()
	get_tree().quit()
	pass

 # Replace with function body.


func _on_btn_play_pressed() -> void:
	Sounds.Click_Sound()
	get_tree().change_scene_to_file("res://option.tscn")
	pass # Replace with function body.
