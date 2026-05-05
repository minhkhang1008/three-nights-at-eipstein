extends Control

@onready var video_player = $VideoStreamPlayer

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Tắt nhạc nền game để nghe âm thanh từ video
	if "bgm_player" in AudioManager:
		AudioManager.bgm_player.stop()
		
	video_player.finished.connect(_on_video_finished)

func _on_video_finished():
	TransitionManager.fade_to_scene("res://credits.scn")
