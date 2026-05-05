extends CharacterBody3D

signal path_finished # Báo cáo đã đi xong đường
signal caught_player # Báo cáo đã tóm được người

@export var move_speed: float = 1.9
var current_path: Array[Vector3] = []
var path_index: int = 0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# --- BIẾN CHO TRUY ĐUỔI TRỰC TIẾP ---
var direct_chase_distance: float = 2.5
var player: Node3D = null 

# --- KHAI BÁO BIẾN SỬA LỖI VÀ QUẢN LÝ ÂM THANH ---
@export var monster_floor: int = 1
var has_spotted_player: bool = false

@onready var anim_player = $quaivat/AnimationPlayer

func _ready():
	if anim_player.has_animation("mixamo_com"):
		anim_player.play("mixamo_com")

func _physics_process(delta):
	# --- BƯỚC 1: TRỌNG LỰC ---
	if not is_on_floor():
		velocity.y -= gravity * delta

	# --- BƯỚC 2: CHIẾN THUẬT CHẠY THẲNG KHI Ở GẦN ---
	if player != null:
		var dist_to_player = global_position.distance_to(player.global_position)
		if dist_to_player < direct_chase_distance:
			
			# --- LOGIC PHÁT TIẾNG HÉT KHI PHÁT HIỆN ---
			if not has_spotted_player:
				has_spotted_player = true # Đánh dấu đã thấy để không hét liên tục
				if monster_floor == 1:
					# Quái tầng 1 (Epstein) hét File 6
					AudioManager.play_voice(load("res://path_to_audio/file6.mp3"))
				else:
					# Quái tầng 2 hét File 10
					AudioManager.play_voice(load("res://path_to_audio/file10.mp3"))
			
			# Xác định điểm nhìn (bỏ qua trục Y để quái vật không bị ngửa mặt)
			var target_look = Vector3(player.global_position.x, global_position.y, player.global_position.z)
			
			if global_position.distance_to(target_look) > 0.1:
				look_at(target_look, Vector3.UP)
				rotate_y(PI) 
			
			var direction = (target_look - global_position).normalized()
			velocity.x = direction.x * move_speed
			velocity.z = direction.z * move_speed
			
			move_and_slide()
			
			if anim_player.current_animation != "mixamo_com":
				anim_player.play("mixamo_com")
				
			_check_player_collision()
			current_path.clear()
			return # Kết thúc vòng lặp tại đây để bỏ qua Dijkstra
			
		else:
			# NẾU PLAYER CHẠY THOÁT KHỎI TẦM ÁP SÁT -> RESET LẠI TIẾNG HÉT
			has_spotted_player = false

	# --- BƯỚC 3: DI CHUYỂN THEO DIJKSTRA ---
	if current_path.size() > 0 and path_index < current_path.size():
		var target_pos = current_path[path_index]
		var direction = Vector3(target_pos.x - global_position.x, 0, target_pos.z - global_position.z).normalized()
		
		if direction.length() > 0.1:
			var look_pos = global_position + direction
			look_at(look_pos, Vector3.UP)
			rotate_y(PI)
			
			velocity.x = direction.x * move_speed
			velocity.z = direction.z * move_speed
		
		move_and_slide()
		
		if anim_player.current_animation != "mixamo_com":
			anim_player.play("mixamo_com")
			
		_check_player_collision()
		
		# Kiểm tra điểm đến
		var flat_global_pos = Vector2(global_position.x, global_position.z)
		var flat_target_pos = Vector2(target_pos.x, target_pos.z)
		
		if flat_global_pos.distance_to(flat_target_pos) < 1.2: 
			path_index += 1
	else:
		# --- BƯỚC 4: KHI ĐÃ ĐI ĐẾN ĐÍCH ĐƯỜNG VẼ ---
		if current_path.size() > 0:
			current_path.clear() 
			path_finished.emit() 
			
		velocity.x = 0
		velocity.z = 0
		move_and_slide()
		
		if anim_player.is_playing():
			anim_player.pause()

# Tách riêng hàm kiểm tra va chạm cho gọn code
func _check_player_collision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() != null and collision.get_collider().name == "Player":
			caught_player.emit()
