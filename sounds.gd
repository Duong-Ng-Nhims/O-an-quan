extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass
	
func Click_Sound():
	%ClickSound.play()
	
func Rai_Quan():
	%RaiQuan.play()
	
func An_Quan():
	%AnQuan.play()

func play_bgm1():
	$BGM2.stop()
	$BGM.play()
	
func play_bgm2():
	$BGM.stop()
	$BGM2.play()
	
func play_gameover():
	$BGM2.stop()
	$GameOver.play()
	
	
	
	
	
	
