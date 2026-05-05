extends Control

@export_category("Kết nối Dữ liệu")
@export var gridmap_node: GridMap 

@export_category("Thông số Vẽ")
@export var tile_size: float = 20.0 
@export var offset: Vector2 = Vector2(200, 100) 

@export_category("Hệ thống Tầng (Floors)")
@export var current_floor: int = 1 
@export var floor1_y_level: int = 1 # Tọa độ Y của BỨC TƯỜNG tầng 1
@export var floor2_y_level: int = 5 # Tọa độ Y của BỨC TƯỜNG tầng 2

@export_category("Hệ thống Lật Map")
@export var is_flipped: bool = true 

var path_to_draw_3d: Array[Vector3] = [] 

func _ready():
	queue_redraw()

# Chuyển đổi giữa Tầng 1 và Tầng 2
func switch_floor(target_floor: int):
	current_floor = target_floor
	queue_redraw()

# Nhận mảng tọa độ 3D từ thuật toán để vẽ đường đỏ
func draw_dijkstra_path(path_3d: Array[Vector3]):
	path_to_draw_3d = path_3d
	queue_redraw()

# Hàm vẽ giao diện chính
func _draw():
	if not gridmap_node: return
	var cells = gridmap_node.get_used_cells()
	if cells.is_empty(): return
	
	var target_y = floor1_y_level
	if current_floor == 2:
		target_y = floor2_y_level

	# --- BƯỚC 1: TÌM TÂM BẢN ĐỒ (Dùng để Lật Map) ---
	var min_x = 999999.0
	var max_x = -999999.0
	var min_z = 999999.0
	var max_z = -999999.0
	var has_walls = false
	
	for cell in cells:
		if cell.y == target_y:
			has_walls = true
			if cell.x < min_x: min_x = cell.x
			if cell.x > max_x: max_x = cell.x
			if cell.z < min_z: min_z = cell.z
			if cell.z > max_z: max_z = cell.z
			
	if not has_walls: return
	
	var center_grid = Vector2((min_x + max_x) / 2.0, (min_z + max_z) / 2.0)
	var center_pixel = center_grid * tile_size
	
	# --- BƯỚC 2: VẼ CÁC BỨC TƯỜNG TRẮNG ---
	for cell in cells:
		if cell.y == target_y:
			var pos_2d = Vector2(cell.x, cell.z) * tile_size
			
			if is_flipped:
				# FIX LỖI 1: Trừ đi tile_size để hình chữ nhật không bị lệch 1 ô khi lật
				pos_2d = (center_pixel * 2.0) - pos_2d - Vector2(tile_size, tile_size)
			
			var final_draw_pos = pos_2d + offset
			
			draw_rect(Rect2(final_draw_pos, Vector2(tile_size, tile_size)), Color.WHITE)
			draw_rect(Rect2(final_draw_pos, Vector2(tile_size, tile_size)), Color(0, 0, 0, 0.5), false, 1.0)

	# --- BƯỚC 3: VẼ ĐƯỜNG DIJKSTRA MÀU ĐỎ & ĐIỂM NEO ---
	if path_to_draw_3d.size() > 1:
		var cell_size_3d = gridmap_node.cell_size 
		
		for i in range(path_to_draw_3d.size() - 1):
			var p1_3d = path_to_draw_3d[i]
			var p2_3d = path_to_draw_3d[i+1]
			
			# Ép 3D thành 2D Grid
			var p1_grid = Vector2(p1_3d.x / cell_size_3d.x, p1_3d.z / cell_size_3d.z)
			var p2_grid = Vector2(p2_3d.x / cell_size_3d.x, p2_3d.z / cell_size_3d.z)
			
			# Chuyển Grid thành Pixel màn hình
			var p1_2d = p1_grid * tile_size
			var p2_2d = p2_grid * tile_size
			
			if is_flipped:
				p1_2d = (center_pixel * 2.0) - p1_2d
				p2_2d = (center_pixel * 2.0) - p2_2d
				
			# FIX LỖI 2: Cộng thêm nửa ô (tile_size/2) để dời điểm vẽ vào giữa đường đi
			var center_shift = Vector2(tile_size / 2.0, tile_size / 2.0)
			p1_2d += offset + center_shift
			p2_2d += offset + center_shift
			
			# Vẽ đường thẳng đỏ
			draw_line(p1_2d, p2_2d, Color.RED, 4.0, true)
			
			# Phân loại màu cho các điểm neo
			if i == 0:
				# Vị trí xuất phát của quái vật (Đỏ, to hơn một chút cho dễ nhìn)
				draw_circle(p1_2d, 8.0, Color.RED)
			else:
				# Các điểm chuyển hướng ở giữa đường đi (Xanh lá)
				draw_circle(p1_2d, 6.0, Color.GREEN)
				
			if i == path_to_draw_3d.size() - 2:
				# Vị trí đích đến của quái vật / Vị trí Player (Xanh dương, to hơn một chút)
				draw_circle(p2_2d, 8.0, Color.BLUE)
