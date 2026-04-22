extends CanvasLayer


func _on_btn_resume_pressed() -> void:
	Sounds.Click_Sound()
	get_tree().paused = false
	queue_free()


func _on_btn_home_pressed() -> void:
	Sounds.Click_Sound()
	get_tree().paused=false
	get_tree().change_scene_to_file("res://main.tscn")
