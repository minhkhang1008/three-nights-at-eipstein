extends Control

# Giữ lại các đường dẫn cần thiết
@onready var main_buttons = $MainButtons

func _ready() -> void:
	# Đảm bảo lúc mới vào game chuột hiện ra để bấm
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Chỉ hiện nhóm nút chính
	main_buttons.show()
	
	# --- 1. NHẠC MENU ---
	AudioManager.play_menu_music(load("res://path_to_audio/menu_music.mp3"))

# --- NHÓM NÚT CHÍNH ---

func _on_continue_button_pressed() -> void:
	# Nhảy thẳng tới map cuối cùng đã lưu
	if GameManager.last_visited_map != "":
		TransitionManager.fade_to_scene(GameManager.last_visited_map)

func _on_start_button_pressed() -> void:
	# --- BẤM START LÀ VÀO THẲNG GAME ---
	# Xóa tiến trình cũ (New Game)
	GameManager.reset_progress()
	# Load thẳng bản đồ map1_scary.scn
	TransitionManager.fade_to_scene("res://Map1/map1_scary.scn")

func _on_settings_button_pressed() -> void:
	print("Mở menu Cài đặt...") 

func _on_credits_button_pressed() -> void:
	print("Mở menu Tác giả...")

# Các hàm liên quan đến chọn phiên bản (Scary/Safe/Back) em có thể xóa hẳn khỏi script 
# hoặc cứ để đó nếu không còn kết nối tín hiệu (Signal) thì cũng không ảnh hưởng gì.
