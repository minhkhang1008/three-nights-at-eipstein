# Locker.gd
extends StaticBody3D

@export var question_data = {
	"question": "Thuật toán Dijkstra có thể xử lý những đồ thị nào sau đây? (Có bao nhiêu phát biểu đúng)\n1. Đồ thị vô hướng\n2. Đồ thị không trọng số\n3. Đồ thị có chu trình âm\n4. Đồ thị có chu trình (trọng số dương)",
	"choices": ["2", "3", "4", "1"],
	"correct_idx": 2 # Lựa chọn "3" là đáp án đúng (vị trí số 2 trong mảng)
}

@onready var interaction_area = $Area3D
@onready var key_model = $KeyModel

var player_ref = null
var is_active = false
var is_waiting_timeout = false
var original_monster_speed = 1.95 

# Bổ sung biến cờ hiệu để biết tủ đã được giải hay chưa
var is_solved = false 

func _ready():
	interaction_area.body_entered.connect(_on_player_enter)
	interaction_area.body_exited.connect(_on_player_exit)
	key_model.hide() # Chắc chắn chìa khóa bị ẩn khi mới vào game

func _on_player_enter(body):
	# Chỉ hiện chữ mở tủ nếu tủ CHƯA được giải
	if body.name == "Player" and not is_solved:
		player_ref = body
		player_ref.interact_label.text = "Press [E] to open Locker"
		player_ref.interact_label.show()

func _on_player_exit(_body):
	_close_quiz()
	player_ref = null

func _process(_delta):
	# Thêm 'not is_solved' để người chơi không bật được bảng câu hỏi khi đã mở tủ
	if player_ref and Input.is_action_just_pressed("interact") and not is_active and not is_solved:
		_start_quiz()

func _input(event):
	if not is_active or is_waiting_timeout: return
	
	var input_map = {
		"A": 1,
		"B": 2,
		"C": 3,
		"D": 4
	}
	
	for key in input_map.keys():
		if event.is_action_pressed(key):
			_check_answer(input_map[key])

func _start_quiz():
	is_active = true
	player_ref.quiz_ui.display(question_data) 
	player_ref.interact_label.hide()
	
	_set_monsters_speed(0.95)

func _check_answer(choice):
	if choice == question_data["correct_idx"]:
		# --- TRẢ LỜI ĐÚNG ---
		is_solved = true # Khóa tủ vĩnh viễn
		key_model.show() # Hiện chìa khóa (Kích hoạt cho script PickupKey hoạt động)
		
		# Vô hiệu hóa vùng tương tác của cái tủ (để nhường phím E cho chìa khóa)
		interaction_area.set_deferred("monitoring", false)
		
		_close_quiz()
		
		# Đổi chữ ngay lập tức để hướng dẫn nhặt
		if player_ref:
			player_ref.interact_label.text = "Click [E] to pick up Key"
			player_ref.interact_label.show()
			
	else:
		# --- TRẢ LỜI SAI ---
		is_waiting_timeout = true
		player_ref.interact_label.text = "Wrong! Wait 2s..."
		player_ref.interact_label.show()
		player_ref.quiz_ui.hide()
		
		await get_tree().create_timer(2.0).timeout
		
		is_waiting_timeout = false
		_close_quiz()

func _close_quiz():
	is_active = false
	
	if player_ref and "quiz_ui" in player_ref and player_ref.quiz_ui != null:
		player_ref.quiz_ui.hide()
		
	_set_monsters_speed(original_monster_speed)

func _set_monsters_speed(speed):
	var monsters = get_tree().get_nodes_in_group("Monsters")
	for m in monsters:
		if "move_speed" in m:
			m.move_speed = speed
