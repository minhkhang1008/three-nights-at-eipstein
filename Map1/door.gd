extends Node3D

@onready var hinge = $Hinge
@onready var interact_area = $InteractArea
# Khai báo UI
@onready var interact_ui = $InteractUI 

var is_open = false
var is_player_near = false

func _ready():
	# Đảm bảo UI luôn tắt khi mới vào game
	interact_ui.hide() 
	interact_area.body_entered.connect(_on_body_entered)
	interact_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player": 
		is_player_near = true
		interact_ui.show() # BẬT CHỮ LÊN

func _on_body_exited(body):
	if body.name == "Player":
		is_player_near = false
		interact_ui.hide() # TẮT CHỮ ĐI

func _input(event):
	if is_player_near and event.is_action_pressed("interact"):
		toggle_door()

func toggle_door():
	is_open = !is_open 
	
	if is_open:
		interact_ui.get_node("Label").text = "Click [E] to close"
	else:
		interact_ui.get_node("Label").text = "Click [E] to open"
	
	# Sử dụng trực tiếp 90.0 và 0.0 độ
	var target_rotation = 122.2 if is_open else 32.2
	
	# Đổi từ "rotation:y" thành "rotation_degrees:y"
	var tween = create_tween()
	tween.tween_property(hinge, "rotation_degrees:y", target_rotation, 0.5).set_trans(Tween.TRANS_SINE)
