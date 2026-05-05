extends Node3D

var astar = AStar3D.new()
var waypoints = {} # Lưu trữ ID của các Marker3D

func _ready():
	# 1. Quét toàn bộ Marker3D và đưa vào đồ thị làm Đỉnh (Nodes)
	var id = 0
	for marker in get_children():
		if marker is Marker3D:
			astar.add_point(id, marker.global_position)
			waypoints[marker.name] = id
			id += 1
			
	# 2. Định nghĩa các Cạnh (Edges) và Trọng số
	# (Em tự nối các điểm có thể đi lại được với nhau)
	connect_waypoints("WP_NgaBa1", "WP_GocCua_NBPN")
	connect_waypoints("WP_GocCua_NBPN", "WP_phongngu")
	connect_waypoints("WP_PlayerSpawn", "WP_NgaBa1")
	connect_waypoints("WP_GocCua_NBPN", "WP_GocCua2")
	connect_waypoints("WP_GocCua2", "WP_GocCua3")
	connect_waypoints("WP_GocCua3", "WP_NgaBa2")
	connect_waypoints("WP_NE", "WP_NgaBa2")
	connect_waypoints("WP_NgaBa2", "WP_NgaBa3")
	connect_waypoints("WP_NW", "WP_NW2")
	connect_waypoints("WP_NW2", "WP_NW3")
	connect_waypoints("WP_NW3", "WP_NW4")
	connect_waypoints("WP_NW4", "WP_NgaBa5")
	connect_waypoints("WP_NgaBa5", "WP_NgaBa6")
	connect_waypoints("WP_NgaBa6", "WP_NgaBa4")
	connect_waypoints("WP_NgaBa4", "WP_Dog")
	connect_waypoints("WP_Dog", "WP_NgaBa3")
	
func connect_waypoints(wp1_name: String, wp2_name: String):
	var id1 = waypoints[wp1_name]
	var id2 = waypoints[wp2_name]
	
	# Godot tự động tính khoảng cách thực tế trong 3D để làm Trọng số (Weight)
	# bidir = true nghĩa là đường 2 chiều
	astar.connect_points(id1, id2, true) 

# Hàm này quái vật sẽ gọi để lấy đường đi ngắn nhất
func get_dijkstra_path(start_wp: String, end_wp: String) -> PackedVector3Array:
	var id1 = waypoints[start_wp]
	var id2 = waypoints[end_wp]
	return astar.get_point_path(id1, id2)
