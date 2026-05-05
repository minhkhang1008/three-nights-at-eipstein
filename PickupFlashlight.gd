extends Area3D

var is_player_near = false
var player_node = null

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player": 
		is_player_near = true
		player_node = body
		# Người chơi tới gần -> Hiện hướng dẫn nhặt
		player_node.interact_label.text = "Click [E] to pick up flashlight"
		player_node.interact_label.show()

func _on_body_exited(body):
	if body.name == "Player":
		is_player_near = false
		# Nếu đi ra xa mà CHƯA nhặt -> Cất chữ đi
		if player_node and not player_node.has_flashlight:
			player_node.interact_label.hide()
		player_node = null

func _process(_delta):
	# Nếu người chơi đứng gần VÀ bấm phím E
	if is_player_near and Input.is_action_just_pressed("interact"):
		# 1. Trang bị vũ khí lên tay
		player_node.has_flashlight = true    
		player_node.flashlight_mesh.show()   
		
		# 2. Đổi chữ thành hướng dẫn bật đèn 
		# (Chữ này sẽ tự biến mất ở file player.gd khi bấm F)
		player_node.interact_label.text = "Click [F] to turn on flashlight"
		
		# 3. Xóa vật phẩm trên bản đồ
		queue_free()
