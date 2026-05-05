extends CanvasLayer

func _ready():
	hide()

func trigger_game_over():
	self.show()
	if has_node("TextureRect"): $TextureRect.show()
	if has_node("Label"): $Label.show()
	
	# Tắt nhạc nền game
	if "bgm_player" in AudioManager:
		AudioManager.bgm_player.stop()
	
	var next_scene_path = "res://credits.scn" 
	
	ResourceLoader.load_threaded_request(next_scene_path)
	
	await get_tree().create_timer(3.0).timeout
	
	var loaded_scene = ResourceLoader.load_threaded_get(next_scene_path)
	
	self.hide()
	get_tree().change_scene_to_packed(loaded_scene)
