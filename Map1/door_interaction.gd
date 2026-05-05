extends Area3D

var player_in_range = false
var player_ref = null
var is_opened = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player" and not is_opened:
		player_in_range = true
		player_ref = body
		player_ref.interact_label.text = "Click [E] to open Door"
		player_ref.interact_label.show()

func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false
		if player_ref and not is_opened:
			player_ref.interact_label.hide()
		player_ref = null

func _process(_delta):
	if player_in_range and not is_opened and Input.is_action_just_pressed("interact"):
		if player_ref and player_ref.has_room_key:
			# --- CÓ CHÌA KHÓA: MỞ CỬA ---
			is_opened = true
			player_ref.interact_label.hide()
			
			# Lệnh xóa cánh cửa vật lý (Node cha của Area3D này) để Player có thể đi qua
			var door_node = get_parent()
			if door_node:
				door_node.queue_free()
				
		else:
			# --- THIẾU CHÌA KHÓA: BÁO LỖI ---
			_show_warning("You need the Room Key from Floor 1 Locker!")

func _show_warning(msg: String):
	if player_ref:
		var label = player_ref.interact_label
		label.text = msg
		await get_tree().create_timer(2.0).timeout
		if player_in_range and not is_opened:
			label.text = "Click [E] to open Door"
