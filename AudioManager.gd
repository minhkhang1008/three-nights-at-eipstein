extends Node

# Các node phát nhạc
@onready var menu_player = AudioStreamPlayer.new()
@onready var bgm_player = AudioStreamPlayer.new()
@onready var vo_player = AudioStreamPlayer.new()

func _ready():
	# Cấu hình các bus
	_setup_player(menu_player, "Music")
	_setup_player(bgm_player, "BGM")
	_setup_player(vo_player, "VO")
	
	# Nhạc nền thường để nhỏ (ví dụ -15dB)
	bgm_player.volume_db = -15.0 

func _setup_player(player, bus_name):
	add_child(player)
	player.bus = bus_name

# Hàm chơi nhạc Menu (Loop)
func play_menu_music(stream: AudioStream):
	if menu_player.stream == stream and menu_player.playing: return
	bgm_player.stop()
	menu_player.stream = stream
	menu_player.play()

# Hàm chơi nhạc nền Game (Loop)
func play_bgm(stream: AudioStream):
	if bgm_player.stream == stream and bgm_player.playing: return
	menu_player.stop()
	bgm_player.stream = stream
	bgm_player.play()

# Hàm phát lồng tiếng (Không loop)
func play_voice(stream: AudioStream):
	vo_player.stream = stream
	vo_player.play()
