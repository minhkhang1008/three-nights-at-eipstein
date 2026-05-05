extends CharacterBody3D

# =========================
# NODE REFERENCES
# =========================
@onready var camera: Camera3D = $Camera3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var flashlight_light: SpotLight3D = $Camera3D/SpotLight3D
@onready var flashlight_mesh: Node3D = $Camera3D/flashlight_mesh 
@onready var interact_label: Label = $CanvasLayer/InteractLabel # Node UI hiển thị chữ
@onready var quiz_ui: Control = $"../CanvasLayer/QuizUI"

# =========================
# CONSTANTS & THÔNG SỐ
# =========================
const SPEED = 1.8
const CROUCH_SPEED = 0.8
const JUMP_VELOCITY = 3.5
const ACCEL = 10.0

const SENSITIVITY_H = 0.002
const SENSITIVITY_V = 0.3
const PITCH_LIMIT_UP := 89.0    
const PITCH_LIMIT_DOWN := -89.0 

const BOB_FREQ = 2.0
const BOB_AMP_Y = 0.015
const BOB_AMP_X = 0.002

# =========================
# STATE VARIABLES
# =========================
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera_pitch := 0.0
var is_crouching := false

var standing_height = 1.112
var standing_cam_pos = 0.5
var crouching_height = 0.6
var crouching_cam_pos = 0.2

var t_bob := 0.0
var flashlight_default_pos: Vector3
var has_flashlight := false 
var has_used_flashlight_once := false # Biến nhớ xem đã bấm F lần nào chưa
var has_room_key := false
var has_window_key := false

# =========================
# HÀM KHỞI TẠO (READY)
# =========================
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	flashlight_default_pos = flashlight_mesh.position
	
	# Giấu mọi thứ đi khi mới vào game
	flashlight_mesh.hide()
	flashlight_light.hide()
	interact_label.hide() 

# =========================
# XỬ LÝ PHÍM & CHUỘT (INPUT)
# =========================
func _input(event: InputEvent) -> void:
	# -- Xoay Camera --
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY_H)
		camera_pitch -= event.relative.y * SENSITIVITY_V
		camera_pitch = clamp(camera_pitch, PITCH_LIMIT_DOWN, PITCH_LIMIT_UP)
		camera.rotation_degrees.x = camera_pitch
			
	# -- Bật/Tắt Đèn pin (Phím F) --
	if event.is_action_pressed("toggle_flashlight"):
		if has_flashlight: 
			flashlight_light.visible = !flashlight_light.visible
			
			# Nếu đây là lần bật đèn đầu tiên -> Giấu dòng chữ vĩnh viễn
			if not has_used_flashlight_once:
				has_used_flashlight_once = true
				interact_label.hide()
				
	# -- Thoát chuột --
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# =========================
# XỬ LÝ VẬT LÝ & DI CHUYỂN
# =========================
func _physics_process(delta: float) -> void:
	# Trọng lực & Nhảy
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Cúi người
	var current_speed = SPEED
	if Input.is_action_pressed("crouch"):
		is_crouching = true
		current_speed = CROUCH_SPEED
		collision_shape.shape.height = lerp(collision_shape.shape.height, crouching_height, 10.0 * delta)
		camera.position.y = lerp(camera.position.y, crouching_cam_pos, 10.0 * delta)
	else:
		is_crouching = false
		current_speed = SPEED
		collision_shape.shape.height = lerp(collision_shape.shape.height, standing_height, 10.0 * delta)
		camera.position.y = lerp(camera.position.y, standing_cam_pos, 10.0 * delta)
		
	# Di chuyển cơ bản
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = lerp(velocity.x, direction.x * current_speed, ACCEL * delta)
		velocity.z = lerp(velocity.z, direction.z * current_speed, ACCEL * delta)
		if is_on_floor():
			t_bob += delta * velocity.length()
	else:
		velocity.x = lerp(velocity.x, 0.0, ACCEL * delta)
		velocity.z = lerp(velocity.z, 0.0, ACCEL * delta)
		t_bob = 0.0 
		
	# Nhún vũ khí (Weapon Bob)
	if has_flashlight:
		var bob_offset = Vector3(
			cos(t_bob * BOB_FREQ / 2.0) * BOB_AMP_X,
			sin(t_bob * BOB_FREQ) * BOB_AMP_Y,      
			0
		)
		flashlight_mesh.position = flashlight_mesh.position.lerp(flashlight_default_pos + bob_offset, 10.0 * delta)
		
	move_and_slide()
