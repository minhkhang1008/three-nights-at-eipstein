extends CanvasLayer

@onready var color_rect = $ColorRect

func _ready():
	# Đảm bảo màng đen tàng hình khi mới mở game
	color_rect.modulate.a = 0.0 

func fade_to_scene(target_path: String):
	# 1. Hiệu ứng mờ dần thành màn đen (trong 0.5 giây)
	var tween_in = create_tween()
	tween_in.tween_property(color_rect, "modulate:a", 1.0, 0.5) 
	await tween_in.finished # Chờ rèm kéo xuống xong
	
	# 2. Chuyển map trong lúc màn hình đang đen xì (Người chơi sẽ không thấy game bị khựng)
	get_tree().change_scene_to_file(target_path)
	
	# 3. Kéo rèm lên từ từ để lộ map mới (trong 0.5 giây)
	var tween_out = create_tween()
	tween_out.tween_property(color_rect, "modulate:a", 0.0, 0.5)
