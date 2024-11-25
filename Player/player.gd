extends CharacterBody3D

@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var MOTION_SPEED = 160 # Pixels/second
@export var FALL_HEIGHT: float = -10

# Vector để lưu hướng di chuyển cuối cùng
@onready var last_direction = Vector3(1, 0, 0)
@onready var start_pos: Vector3 = position

# Dictionary chứa các animation states
var anim_directions = {
	"idle": [ # list of [animation name, horizontal flip]
		["right_idle", false],
		["front_right_idle", false], 
		["front_idle", false],
		["front_left_idle", false],
		["left_idle", false],
		["back_left_idle", false],
		["back_idle", false],
		["back_right_idle", false],
	],
	"walk": [
		["right_walk", false],
		["front_right_walk", false],
		["front_walk", false],
		["front_left_walk", false],
		["left_walk", false],
		["back_left_walk", false],
		["back_walk", false],
		["back_right_walk", false],
	],
	"jump": [
		["right_jump", false],
		["front_right_jump", false],
		["front_jump", false],
		["front_left_jump", false],
		["left_jump", false],
		["back_left_jump", false],
		["back_jump", false],
		["back_right_jump", false],
	],
}

func _ready() -> void:
	add_to_group("trigger")

func _physics_process(delta: float) -> void:
	# Xử lý gravity
	check_fall()
	if not is_on_floor():
		if velocity.y < 0:
			velocity += get_gravity() * delta * 2.5
		else:
			velocity += get_gravity() * delta

	# Xử lý nhảy
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Lấy input direction và xử lý movement
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	## Cập nhật velocity dựa trên input
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		last_direction = direction
		if not is_on_floor():
			update_animation("jump")
		else:
			update_animation("walk")
	else:
		velocity.x = 0
		velocity.z = 0
		if not is_on_floor():
			update_animation("jump")
		else:
			update_animation("idle")

	move_and_slide()

func update_animation(anim_set: String) -> void:
	# Chuyển đổi vector3 thành vector2 để tính góc (bỏ qua trục y)
	var dir_2d = Vector2(last_direction.x, last_direction.z)
	
	# Tính góc và slice direction
	var angle = rad_to_deg(dir_2d.angle()) + 22.5
	var slice_dir = int(fmod(floor(angle / 45), 8))  # Đảm bảo giá trị từ 0-7
	
	# Lấy reference đến AnimationPlayer hoặc AnimatedSprite3D
	$Char.play(anim_directions[anim_set][slice_dir][0])
func check_fall() -> void:
	if position.y < FALL_HEIGHT:
		restart()
	
func restart() -> void:
	position = start_pos
	velocity = Vector3.ZERO
