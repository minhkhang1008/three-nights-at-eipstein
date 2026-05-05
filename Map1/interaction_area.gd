extends Area3D

@export var interaction_label: Label 

var player_in_range = false
var player_ref = null

func _ready():
	if interaction_label:
		interaction_label.hide()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = true
		player_ref = body 
		if interaction_label:
			interaction_label.text = "Click [E] to open Window"
			interaction_label.show()

func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false
		player_ref = null
		if interaction_label:
			interaction_label.hide()

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		if player_ref and player_ref.has_window_key:
			# TRƯỜNG HỢP CÓ CHÌA KHÓA CỬA SỔ
			if interaction_label:
				interaction_label.hide() # Ẩn text đi cho gọn
				
			# Gọi hàm lồng tiếng (File 11) và chuyển sang Win Ending bên file map_1_scary.gd
			if get_tree().current_scene.has_method("trigger_escape_voice"):
				get_tree().current_scene.trigger_escape_voice()
				
			# Tắt process để người chơi không bấm [E] spam được nữa
			set_process(false) 
		else:
			# TRƯỜNG HỢP THIẾU CHÌA KHÓA
			_show_warning("You need the Window Key to open this!")

func _show_warning(msg: String):
	if interaction_label:
		interaction_label.text = msg
		await get_tree().create_timer(2.0).timeout
		if player_in_range:
			interaction_label.text = "Click [E] to open Window"
