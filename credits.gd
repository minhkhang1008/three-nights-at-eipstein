extends Control

@onready var video_player = $VideoStreamPlayer

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Tắt nhạc nền game (phòng trường hợp chuyển từ Game Over qua)
	if "bgm_player" in AudioManager:
		AudioManager.bgm_player.stop()
		
	video_player.finished.connect(_on_video_finished)

func _on_video_finished():
	GameManager.reset_progress()
	TransitionManager.fade_to_scene("res://main_menu.scn")

func _on_skip_button_pressed():
	video_player.stop()
	GameManager.reset_progress()
	TransitionManager.fade_to_scene("res://main_menu.scn")
