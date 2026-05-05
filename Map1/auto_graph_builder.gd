extends Node
class_name AutoGraphBuilder

var astar = AStar3D.new()
var grid_to_id = {}
var id_to_grid = {}

@export var gridmap_node: GridMap
@export var floor_y: int = 0 # Tọa độ Y của mặt sàn (nơi đi lại được)

func _ready():
	# Đợi 1 frame để đảm bảo GridMap đã load xong xuôi mới bắt đầu quét
	call_deferred("build_optimized_graph")

func build_optimized_graph():
	astar.clear()
	grid_to_id.clear()
	id_to_grid.clear()
	if not gridmap_node:
		print("LỖI: Chưa kết nối GridMap vào AutoGraphBuilder!")
		return
		
	var cells = gridmap_node.get_used_cells()
	var walkable_cells = {}
	
	# --- BƯỚC A: LỌC TẤT CẢ CÁC Ô ĐI ĐƯỢC (DƯỚI SÀN, KHÔNG BỊ TƯỜNG ĐÈ) ---
	for cell in cells:
		# Nếu là ô Sàn Nhà
		if cell.y == floor_y:
			# Kiểm tra xem ngay trên ô Sàn Nhà này có bị Tường đè lên không
			var wall_check = Vector3i(cell.x, floor_y + 1, cell.z)
			if gridmap_node.get_cell_item(wall_check) == GridMap.INVALID_CELL_ITEM:
				# Ô trống hoàn toàn -> Đánh dấu là đi được
				walkable_cells[Vector2i(cell.x, cell.z)] = true

	# --- BƯỚC B: TẠO NODE A* CHO MỌI Ô TRỐNG (GIÚP CUỐN CUA CHUẨN) ---
	var current_id = 0
	for cell_2d in walkable_cells.keys():
		# Đổi Tọa độ Grid -> Local -> Global cực chuẩn
		var local_pos = gridmap_node.map_to_local(Vector3i(cell_2d.x, floor_y, cell_2d.y))
		var global_pos = gridmap_node.to_global(local_pos)
		
		astar.add_point(current_id, global_pos)
		
		grid_to_id[cell_2d] = current_id
		id_to_grid[current_id] = cell_2d
		current_id += 1

	# --- BƯỚC C: NỐI CÁC Ô NẰM CẠNH NHAU ---
	var directions = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0)]
	
	for start_id in id_to_grid.keys():
		var start_cell = id_to_grid[start_id]
		
		for dir in directions:
			var neighbor_cell = start_cell + dir
			
			# Nếu ô bên cạnh cũng là sàn nhà trống thì nối chúng lại với nhau
			if grid_to_id.has(neighbor_cell):
				var target_id = grid_to_id[neighbor_cell]
				astar.connect_points(start_id, target_id, true)
				
# Hàm tính toán Dijkstra trả về mảng tọa độ 3D
func get_optimized_path(start_pos_3d: Vector3, end_pos_3d: Vector3) -> Array[Vector3]:
	if astar.get_point_count() == 0: return []
	
	# Tìm đỉnh gần nhất với Quái vật và Người chơi
	var start_id = astar.get_closest_point(start_pos_3d)
	var end_id = astar.get_closest_point(end_pos_3d)
	
	var packed_path = astar.get_point_path(start_id, end_id)
	var array_path: Array[Vector3] = []
	for p in packed_path:
		array_path.append(p)
		
	return array_path
