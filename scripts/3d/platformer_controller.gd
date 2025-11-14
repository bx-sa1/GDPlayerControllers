@tool
class_name PlatformerController extends BaseController

@export var JUMP_ACCEL = 5
@export var TURN_SPEED = 30

var last_move_dir = Vector3.FORWARD

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	camera_controller.rotation.y = yaw
	camera_controller.rotation.x = pitch

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	var idir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var dir = (camera_controller.camera.global_basis * Vector3(idir.x, 0.0, idir.y)).normalized()
	dir.y = 0.0
	var y_vel = velocity.y
	velocity = velocity.move_toward(dir * MOVE_SPEED, MOVE_ACCEL * delta)
	velocity.y = y_vel - GRAVITY * delta
	if is_on_floor() && Input.is_action_pressed("jump"):
		self.velocity.y += JUMP_ACCEL

	move_and_slide()

	if dir.length() > 0.0:
		last_move_dir = dir
	var visual_target_angle = Vector3.FORWARD.signed_angle_to(last_move_dir, Vector3.UP)
	visual.global_rotation.y = lerp_angle(visual.rotation.y, visual_target_angle, TURN_SPEED * delta)
