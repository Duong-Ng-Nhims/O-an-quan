extends Area2D

signal directional_selected(direction)

@onready var arrow = $Arrow

func _ready():
	arrow.hide()
	
var can_click: bool = true 

func _input_event(viewport, event, shape_idx):
	if not can_click: return 
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if can_click:
			var playground = get_tree().current_scene
			if playground.has_method("clear_all_arrows"):
				playground.clear_all_arrows()
			hien_mui_ten()
			
func hien_mui_ten():
	arrow.show()
	
func _on_btn_left_pressed() -> void:
	arrow.hide()
	directional_selected.emit(-1)
	
	
	
	
func _on_btn_right_pressed() -> void:
	arrow.hide()
	directional_selected.emit(1)
