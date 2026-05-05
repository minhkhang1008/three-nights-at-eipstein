extends Control

# --- DỮ LIỆU ĐỒ THỊ ---
# Nodes: {"Tên_Đỉnh": Vector2(Tọa độ trên ảnh)}
var graph_nodes = {
	"Spawn": Vector2(100, 100),
	"NgaBa": Vector2(300, 100),
	"CauThang": Vector2(300, 400),
	"Player_Pos": Vector2(500, 400)
}

# Edges: [Đỉnh 1, Đỉnh 2, Trọng số]
var graph_edges = [
	["Spawn", "NgaBa", 10],
	["NgaBa", "CauThang", 25],
	["CauThang", "Player_Pos", 12]
]

var path_to_draw = [] # Chứa danh sách các đỉnh trong đường đi ngắn nhất
var animation_index = 0
@onready var timer = $DrawTimer

func find_shortest_path(start, end):
	# Sử dụng Dictionary làm bảng khoảng cách và vết (parent)
	var dist = {}
	var prev = {}
	var pq = [] # Em có thể dùng Array rồi sort lại để giả lập Priority Queue
	
	for node in graph_nodes:
		dist[node] = INF
		prev[node] = null
	
	dist[start] = 0
	pq.append([0, start])
	
	while pq.size() > 0:
		pq.sort_custom(func(a, b): return a[0] < b[0]) # Sort theo trọng số
		var u = pq.pop_front()[1]
		
		if u == end: break
		
		for edge in graph_edges:
			var v = ""
			if edge[0] == u: v = edge[1]
			elif edge[1] == u: v = edge[0]
			
			if v != "":
				var alt = dist[u] + edge[2]
				if alt < dist[v]:
					dist[v] = alt
					prev[v] = u
					pq.append([alt, v])
					
	# Tái tạo đường đi từ mảng prev
	var path = []
	var curr = end
	while curr != null:
		path.push_front(curr)
		curr = prev[curr]
	return path

# --- HÀM KÍCH HOẠT TỪ QUÁI VẬT ---
func show_monster_path(start_node: String, end_node: String):
	self.show() # Hiện bản đồ lên
	# 1. Chạy thuật toán Dijkstra (Sẽ viết ở Bước 4)
	path_to_draw = find_shortest_path(start_node, end_node)
	
	# 2. Bắt đầu Animation vẽ đường đi
	animation_index = 0
	timer.start(0.5) # Cứ 0.5s vẽ thêm 1 đoạn
	queue_redraw()

func _on_draw_timer_timeout():
	if animation_index < path_to_draw.size() - 1:
		animation_index += 1
		queue_redraw()
		timer.start(0.5)
	else:
		# Sau khi vẽ xong, chờ 2 giây rồi ẩn bản đồ đi để người chơi tiếp tục chơi
		await get_tree().create_timer(2.0).timeout
		self.hide()

# --- HÀM VẼ GIAO DIỆN ---
func _draw():
	# Vẽ các cạnh mờ mờ (Khung xương đồ thị)
	for edge in graph_edges:
		var p1 = graph_nodes[edge[0]]
		var p2 = graph_nodes[edge[1]]
		draw_line(p1, p2, Color(0.5, 0.5, 0.5, 0.5), 2.0) # Màu xám mờ
		
		# Vẽ trọng số
		var mid = (p1 + p2) / 2
		draw_string(ThemeDB.fallback_font, mid, str(edge[2]), HORIZONTAL_ALIGNMENT_CENTER, -1, 14)

	# Vẽ đường đi quái vật đã chọn (Màu đỏ tươi rực lên)
	if path_to_draw.size() > 1:
		for i in range(animation_index):
			var p1 = graph_nodes[path_to_draw[i]]
			var p2 = graph_nodes[path_to_draw[i+1]]
			draw_line(p1, p2, Color.RED, 5.0, true) # Đường đỏ đậm
			# Vẽ mũi tên hướng đi nếu muốn
