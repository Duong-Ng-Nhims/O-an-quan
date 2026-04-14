extends Node2D
	
var stone_scene=preload("res://stone.tscn")
var mandarine_stone_scene = preload("res://mandarine_stone.tscn")
var game_over_scene = preload("res://game_over.tscn")
@onready var holes = $board_manager/holes.get_children()
@onready var mandarineHoles = $board_manager/mandarineHoles.get_children()
@onready var stones_container = $board_manager/stonesContainer
@onready var p1 = $P1
@onready var p2 = $P2
@onready var score_label_1 = $scoreLabel1
@onready var score_label_2 = $scoreLabel2
@onready var p1_marker = $board_manager/basketP1/stonePoint1
@onready var p2_marker = $board_manager/basketP2/stonePoint2

var score1: int = 0
var score2: int = 0
var current_turn = 1
var is_busy: bool = false
var all_slot = []

func _on_btn_home_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
	
func _ready():
	setup_all_slot()
	setup_board()
	await get_tree().process_frame
	for h in holes:
		update_stone_number(h)
	for m in mandarineHoles:
		update_stone_number(m)
	permition_to_double_click()
	bat_dau_luot(1)
	for hole in holes:
		if hole.has_signal("directional_selected"):
			hole.directional_selected.connect(_on_hole_selected.bind(hole))

func setup_all_slot():
	all_slot.clear()
	for i in range(5):
		all_slot.append(holes[i])
	all_slot.append(mandarineHoles[1])
	for i in range(5,10):
		all_slot.append(holes[i])
	all_slot.append(mandarineHoles[0])
	
func setup_board():
	clear_all_stones()
	
	for hole in holes:
		for i in range(5):
			add_stone_to_hole(hole, stone_scene)
			
	for m_hole in mandarineHoles:
		add_stone_to_hole(m_hole, mandarine_stone_scene, true)
			
func add_stone_to_hole(hole_node, scene_to_use, is_mandarine=false):
	var stone = scene_to_use.instantiate()
	var range_x = 20
	var range_y = 20 if not is_mandarine else 45
	var offset = Vector2(randf_range(-range_x, range_x), randf_range(-range_y, range_y))
	stone.global_position = hole_node.global_position + offset
	stones_container.add_child(stone)
	
func clear_all_stones():
	for child in stones_container.get_children():
		child.queue_free()

func bat_dau_luot(player_id):
	current_turn = player_id
	is_busy = true
	await  get_tree().process_frame
	await get_tree().process_frame
	if player_het_soi(player_id):
		lay_soi_tu_gio(player_id)
		await get_tree().process_frame
		for h in holes: update_stone_number(h)
		
	is_busy = false
	permition_to_double_click()
	if player_id == 1:
		p1.set_active(true)
		p1.reset_timer()
		p2.set_active(false)
		p2.stop_timer()
	else:
		p2.set_active(true)
		p2.reset_timer()
		p1.set_active(false)
		p1.stop_timer()

func ket_thuc_luot():
	bat_dau_luot(2 if current_turn == 1 else 1)

func player_het_soi(player_id) -> bool:
	var start_idx = 0 if player_id == 1 else 5
	var end_idx = 4 if player_id == 1 else 9
	for i in range(start_idx, end_idx+1):
		var hole = holes[i]
		for stone in stones_container.get_children():
			if not stone.is_queued_for_deletion() and stone.global_position.distance_to(hole.global_position)<30:
				return false
	return true
	
func lay_soi_tu_gio(player_id):
	if player_id == 1:
		score1 -= 5
	else:
		score2 -= 5
	cap_nhat_diem()
	
	var start_idx = 0 if player_id == 1 else 5
	var end_idx = 4 if player_id == 1 else 9
	for i in range(start_idx, end_idx+1):
		var  target_hole = holes[i]
		them_mot_vien_soi(target_hole)
	xoa_bot_soi_trong_gio(player_id, 5)

func _on_p_1_het_gio() -> void:
	print("player 1 timeout")
	bat_dau_luot(2)


func _on_p_2_het_gio() -> void:
	print("player 2 timeout")
	bat_dau_luot(1)
	
func rai_soi(start_hole, direction):
	var current_idx = all_slot.find(start_hole)
	var so_soi_rai = get_stone_in_hole(start_hole)
	await clear_stones_in_hole(start_hole)
	
	while so_soi_rai > 0:
		while so_soi_rai > 0:
			current_idx = (current_idx + direction + all_slot.size()) % all_slot.size()
			var target_hole = all_slot[current_idx]
			them_mot_vien_soi(target_hole)
			so_soi_rai -= 1
			await get_tree().create_timer(0.5).timeout
		
		var next_idx = (current_idx + direction + all_slot.size()) % all_slot.size()
		var next_hole = all_slot[next_idx]
		var stone_next_hole = get_stone_in_hole(next_hole)
	
		if next_hole in mandarineHoles:
			ket_thuc_luot()
			return
	
		if stone_next_hole > 0:
			so_soi_rai = stone_next_hole
			await clear_stones_in_hole(next_hole)
			current_idx = next_idx
			await get_tree().create_timer(0.5).timeout
			
		else:
			var eat_idx = (next_idx + direction + all_slot.size()) % all_slot.size()
			await an_quan(eat_idx, direction)
			ket_thuc_luot()
			return
	ket_thuc_luot()
	
func get_stone_in_hole(hole_node):
	var count = 0
	for stone in stones_container.get_children():
		if not stone.is_queued_for_deletion() and stone.global_position.distance_to(hole_node.global_position) < 28:
			count += 1
	return count
	
func update_stone_number(hole_node):
	var count = get_stone_in_hole(hole_node)
	if hole_node.has_node("stoneCountLabel"):
		var label = hole_node.get_node("stoneCountLabel")
		label.text = str(count)
		label.visible = (count > 0)
	
func them_mot_vien_soi(hole_node, is_mandarine_stone = false):
	var scene_to_use = mandarine_stone_scene if is_mandarine_stone else stone_scene
	var stone = scene_to_use.instantiate()
	var offset = Vector2(randf_range(-15, 15), randf_range(-15, 15))
	stone.global_position = hole_node.global_position + offset
	stones_container.add_child(stone)
	update_stone_number(hole_node)
	
func clear_stones_in_hole(hole_node):
	for stone in stones_container.get_children():
		if stone.global_position.distance_to(hole_node.global_position) < 30:
			stone.queue_free()
	await  get_tree().process_frame
	update_stone_number(hole_node)
			
func an_quan(eat_idx, direction):
	var target_hole = all_slot[eat_idx]
	var stones_to_eat = get_stone_in_hole(target_hole)
	
	if stones_to_eat > 0:
		var points_earned = 0
		var is_mandarine = target_hole in mandarineHoles
		if is_mandarine:
			points_earned = 10 + (stones_to_eat - 1) 
		else:
			points_earned = stones_to_eat
		
		if current_turn == 1:
			score1 += points_earned
		else:
			score2 += points_earned
			
		bo_vao_gio(current_turn, stones_to_eat, is_mandarine)
			
		await clear_stones_in_hole(target_hole)
		
		cap_nhat_diem()
		kiem_tra_ket_thuc()
		var next_empty_idx = (eat_idx + direction + all_slot.size()) % all_slot.size()
		var next_eat_idx = (next_empty_idx + direction + all_slot.size()) % all_slot.size()
		
		if get_stone_in_hole(all_slot[next_empty_idx]) == 0:
			if get_stone_in_hole(all_slot[next_eat_idx]) > 0:
				await get_tree().create_timer(0.5).timeout
				await an_quan(next_eat_idx, direction)
			
func cap_nhat_diem():
	score_label_1.text = "Player 1 score: "+ str(score1)
	score_label_2.text = "Player 2 score: "+ str(score2)

func _on_hole_selected(direction: int, hole_node: Area2D):
	if is_busy: 
		return
		
	if not is_my_turn_hole(hole_node):
		return
		
	if get_stone_in_hole(hole_node) == 0:
		return

	if current_turn == 1: p1.stop_timer()
	else: p2.stop_timer()

	var real_direction = direction
	var idx = holes.find(hole_node)
	if idx >= 5 and idx <=9:
		real_direction = direction * -1
	is_busy = true
	clear_all_arrows() 
	await rai_soi(hole_node, real_direction)
	
func clear_all_arrows():
	for h in holes:
		h.arrow.hide()
	for m in mandarineHoles:
		m.arrow.hide()

func is_my_turn_hole(hole_node) -> bool:
	var idx = holes.find(hole_node)
	if current_turn == 1:
		return idx >= 0 and idx <= 4 
	else:
		return idx >= 5 and idx <= 9 

func permition_to_double_click():
	for i in range(holes.size()):
		var hole_node = holes[i]
		if current_turn == 1:
			hole_node.can_click = (i >= 0 and i <= 4)
		else:
			hole_node.can_click = (i >= 5 and i <= 9)
		
		if not hole_node.can_click:
			hole_node.arrow.hide()
	
	for m_hole in mandarineHoles:
		m_hole.can_click = false
		m_hole.get_node("Arrow").hide()

func them_mot_vien_vao_gio(marker_node, scene_to_use):
	if scene_to_use == null:
		print("Loi")
		return
	var stone = scene_to_use.instantiate()
	var range_random = 50
	var offset = Vector2(randf_range(-range_random, range_random), randf_range(-range_random, range_random))
	stone.global_position = marker_node.global_position + offset
	stones_container.add_child(stone)
	
func xoa_bot_soi_trong_gio(player_id, so_luong):
	var target_marker = p1_marker if player_id == 1 else p2_marker
	var deleted_count = 0
	var all_stones = stones_container.get_children()
	all_stones.reverse()
	for stone in all_stones:
		if deleted_count >= so_luong: break
		if stone.global_position.distance_to(target_marker.global_position) < 60:
			stone.queue_free()
			deleted_count +=1

func bo_vao_gio(player_id: int, so_luong: int, quan:bool = false):
	var target_marker = p1_marker if player_id == 1 else p2_marker
	if quan:
		for i in range(5):
			them_mot_vien_vao_gio(target_marker, stone_scene)
		if so_luong > 1:
			for i in range(so_luong - 1):
				them_mot_vien_vao_gio(target_marker, stone_scene)
	else:
		var limit_display = min(so_luong, 10)
		for i in range(limit_display):
			them_mot_vien_vao_gio(target_marker, stone_scene)

func kiem_tra_ket_thuc():
	var quan_het_soi = true
	for m in mandarineHoles:
		if get_stone_in_hole(m) > 0: 
			quan_het_soi = false 
			break
	if quan_het_soi:
		is_busy = true
		thu_dan_con_lai()
		hien_thi_man_hinh_ket_thuc()

func thu_dan_con_lai():
	for i in range(5):
		score1 += get_stone_in_hole(holes[i])
		clear_stones_in_hole(holes[i])
	for i in range(5, 10):
		score2 += get_stone_in_hole(holes[i])
		clear_stones_in_hole(holes[i])
	cap_nhat_diem()
	
func hien_thi_man_hinh_ket_thuc():
	p1.stop_timer()
	p2.stop_timer()
	
	var end_screen = game_over_scene.instantiate()
	add_child(end_screen)
	
	var winner_text = ""
	if score1 > score2:
		winner_text = "<Player 1 won>"
	elif score2 > score1:
		winner_text = "<Player 2 won>"
	else:
		winner_text = "Draw!"
	
	var lbl_winner = end_screen.find_child("winnerLabel", true, false)
	var lbl_score = end_screen.find_child("scoreLabel", true, false)
	var btn_replay = end_screen.find_child("btn_replay", true, false)
	var btn_home = end_screen.find_child("btn_home", true, false)
	if lbl_winner:
		lbl_winner.text = winner_text
	else: 
		print("khong tim thay node winnerLabel")
	if lbl_score:
		lbl_score.text = "P1: %d	|	P2: %d" %[score1, score2]
	if btn_replay:
		btn_replay.pressed.connect(self._on_btn_replay_pressed)
	if btn_home:
		btn_home.pressed.connect(self._on_btn_home_pressed)


func _on_btn_replay_pressed() -> void:
	get_tree().reload_current_scene()
