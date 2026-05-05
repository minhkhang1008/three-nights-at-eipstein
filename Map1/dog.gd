extends CharacterBody3D

@onready var detection_radar = $DetectionRadar
# 1. Gọi Node âm thanh vào code
@onready var bark_sound = $BarkSound 

var is_alerted = false
var target_player = null

func _ready():
	print("--- HỆ THỐNG CHÓ BÁO ĐỘNG ĐÃ KHỞI ĐỘNG ---")

func _process(_delta):
	if is_alerted and target_player != null:
		var target_pos = target_player.global_position
		target_pos.y = global_position.y 
		look_at(target_pos, Vector3.UP)

func _on_detection_radar_body_entered(body: Node3D) -> void:
	if body.name == "Player" and not is_alerted:
		is_alerted = true
		target_player = body
		
		# 2. Bấm nút Play phát âm thanh!
		bark_sound.play() 
		
		print("GÂU GÂU GÂU! PHÁT HIỆN BÉ GÁI!")
		
		# TÌM ĐẾN NODE GỐC (MAP1HOUSE) VÀ KÍCH HOẠT SỰ KIỆN SPAWN QUÁI VẬT
		get_tree().current_scene.spawn_and_hunt()
