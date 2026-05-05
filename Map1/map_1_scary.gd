extends Node3D

@export var gridmap_node: GridMap
@export var monster_scene: PackedScene
@export var player: CharacterBody3D
@export var graph_builder: AutoGraphBuilder
@export var dijkstra_ui_root: Control 
@export var map_painter: Node 

var monster1: CharacterBody3D = null
var monster2: CharacterBody3D = null
var current_active_monster: CharacterBody3D = null
var current_floor: int = 1
var is_hunting: bool = false

# --- CÁC BIẾN CỜ ĐỂ TRÁNH PHÁT THOẠI LẶP LẠI ---
var has_played_file5: bool = false
var has_played_file8: bool = false
var has_played_file9: bool = false

func _ready():
	GameManager.save_progress("res://Map1/map_1_scary.tscn")
	
	AudioManager.play_bgm(load("res://path_to_audio/bgm.mp3"))
	play_intro_voice() 
	
	call_deferred("spawn_and_hunt")

# Thoại mở đầu (File 1 và File 2)
func play_intro_voice():
	await get_tree().create_timer(1.0).timeout
	AudioManager.play_voice(load("res://path_to_audio/file1.mp3"))
	await AudioManager.vo_player.finished
	AudioManager.play_voice(load("res://path_to_audio/file2.mp3"))

func spawn_and_hunt():
	if is_hunting: return 
	is_hunting = true 
	
	if not gridmap_node or not monster_scene: return

	# KHỞI TẠO QUÁI VẬT TẦNG 1
	monster1 = monster_scene.instantiate()
	monster1.player = player
	monster1.name = "Monster1"
	monster1.monster_floor = 1 
	add_child(monster1)
	
	var spawn_points_f1 = [
		Vector3(3.395, 1.158, 19.43),   
		Vector3(23.69, 1.158, 19.43)    
	]
	monster1.global_position = spawn_points_f1.pick_random()
	
	# KHỞI TẠO QUÁI VẬT TẦNG 2
	monster2 = monster_scene.instantiate()
	monster2.player = player
	monster2.name = "Monster2"
	monster2.monster_floor = 2 
	add_child(monster2)
	
	monster2.global_position = Vector3(26.71, 5.214, 17.94)
	
	for m in [monster1, monster2]:
		m.path_finished.connect(_on_monster_needs_new_path)
		m.caught_player.connect(_on_game_over)
	
	_switch_active_monster(1)

func _process(_delta):
	if not is_hunting: return
	
	if player.global_position.y >= 3.5 and current_floor == 1:
		_switch_active_monster(2)
	elif player.global_position.y < 3.5 and current_floor == 2:
		_switch_active_monster(1)

func _switch_active_monster(floor_target: int):
	current_floor = floor_target
	
	if current_floor == 1:
		current_active_monster = monster1
		_toggle_monster_logic(monster1, true)
		_toggle_monster_logic(monster2, false)
		graph_builder.floor_y = 0 
	else:
		current_active_monster = monster2
		_toggle_monster_logic(monster2, true)
		_toggle_monster_logic(monster1, false)
		# --- ĐÃ FIX: Sửa thành 5 để nhận diện đúng mặt sàn tầng 2 ---
		graph_builder.floor_y = 4
	
	if map_painter.has_method("switch_floor"):
		map_painter.switch_floor(current_floor)
	
	graph_builder.build_optimized_graph()
	trigger_ui_and_run()

func _toggle_monster_logic(monster: CharacterBody3D, active: bool):
	if monster:
		monster.set_physics_process(active)
		monster.current_path.clear()
		if active:
			if monster.anim_player.has_animation("mixamo_com"):
				monster.anim_player.play("mixamo_com")
		else:
			monster.anim_player.pause()
			monster.velocity = Vector3.ZERO

func _on_monster_needs_new_path():
	if current_active_monster and player:
		var dist = current_active_monster.global_position.distance_to(player.global_position)
		if dist > 2.0:
			await get_tree().create_timer(0.5).timeout 
			trigger_ui_and_run()

func trigger_ui_and_run():
	if not current_active_monster or not player: return
	
	var the_path = graph_builder.get_optimized_path(current_active_monster.global_position, player.global_position)
	
	# --- ĐÃ FIX: Chống kẹt vòng lặp quái vật đứng im ---
	if the_path.size() <= 1:
		print("[DEBUG] Quái vật tầng ", current_floor, " không tìm thấy đường đi! Đang thử lại...")
		await get_tree().create_timer(1.0).timeout
		if is_hunting:
			trigger_ui_and_run()
		return
	
	dijkstra_ui_root.show()
	map_painter.draw_dijkstra_path(the_path)
	
	current_active_monster.current_path = the_path
	current_active_monster.path_index = 0
	
	await get_tree().create_timer(3.0).timeout
	
	if is_instance_valid(dijkstra_ui_root):
		dijkstra_ui_root.hide()

func _on_dog_bark():
	# THOẠI KHI CHÓ SỦA (File 7)
	AudioManager.play_voice(load("res://path_to_audio/file7.mp3"))
	
	if current_active_monster:
		current_active_monster.current_path.clear()
		trigger_ui_and_run()

func _on_game_over():
	is_hunting = false
	for m in [monster1, monster2]:
		if m:
			m.set_physics_process(false)
			m.anim_player.pause()
	GameOverManager.trigger_game_over()

# ==========================================
# CÁC HÀM XỬ LÝ ÂM THANH KHI VA CHẠM TƯƠNG TÁC
# ==========================================

# Gọi hàm này khi nhân vật mở cửa thành công (File 3 & 4)
func trigger_door_voice():
	AudioManager.play_voice(load("res://path_to_audio/file3.mp3"))
	await AudioManager.vo_player.finished
	AudioManager.play_voice(load("res://path_to_audio/file4.mp3"))

# Gọi hàm này khi nhân vật nhảy thoát cửa sổ (File 11)
func trigger_escape_voice():
	AudioManager.play_voice(load("res://path_to_audio/file11.mp3"))
	await AudioManager.vo_player.finished
	
	# CHUYỂN SANG VIDEO WIN
	TransitionManager.fade_to_scene("res://win_ending.scn")

# File 5: Thấy Epstein lần đầu (Nối từ Area3D)
func _on_first_sight_epstein_area_body_entered(body: Node3D):
	if body.name == "Player" and not has_played_file5:
		has_played_file5 = true
		AudioManager.play_voice(load("res://path_to_audio/file5.mp3"))

# File 8: Bước vào phòng chứa xác chết (Nối từ Area3D)
func _on_corpse_room_area_body_entered(body: Node3D):
	if body.name == "Player" and not has_played_file8:
		has_played_file8 = true
		AudioManager.play_voice(load("res://path_to_audio/file8.mp3"))

# File 9: Nhìn thấy cửa sổ thoát hiểm (Nối từ Area3D)
func _on_window_sight_area_body_entered(body: Node3D):
	if body.name == "Player" and not has_played_file9:
		has_played_file9 = true
		AudioManager.play_voice(load("res://path_to_audio/file9.mp3"))
