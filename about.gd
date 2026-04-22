extends Node2D


func _on_btn_home_pressed() -> void:
	Sounds.Click_Sound()
	get_tree().change_scene_to_file("res://main.tscn")


func _on_btn_sound_pressed() -> void:
	Sounds.Click_Sound() 
	pass # Replace with function body.


func _on_btn_sound_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0, toggled_on)
	pass # Replace with function body.
	
func _ready() -> void:
	$btn_sound.button_pressed=AudioServer.is_bus_mute(0)
