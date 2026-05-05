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
		player_node.interact_label.text = "Click [E] to pick up Window Key"
		player_node.interact_label.show()

func _on_body_exited(body):
	if body.name == "Player":
		is_player_near = false
		if player_node and not player_node.has_window_key:
			player_node.interact_label.hide()
		player_node = null

func _process(_delta):
	if is_player_near and Input.is_action_just_pressed("interact"):
		# Cấp chìa khóa cửa sổ cho Player
		player_node.has_window_key = true
		
		player_node.interact_label.text = "Window Key picked up"
		player_node.interact_label.show()
		
		var label_to_hide = player_node.interact_label
		get_tree().create_timer(2.0).timeout.connect(func():
			if is_instance_valid(label_to_hide) and label_to_hide.text == "Window Key picked up":
				label_to_hide.hide()
		)
		
		queue_free()
