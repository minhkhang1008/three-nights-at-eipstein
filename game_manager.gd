extends Node

# Biến lưu đường dẫn map cuối cùng người chơi đã đặt chân đến
var last_visited_map: String = ""

# Hàm lưu tiến trình
func save_progress(map_path: String):
	last_visited_map = map_path

# Hàm xóa tiến trình (khi chọn New Game)
func reset_progress():
	last_visited_map = ""
