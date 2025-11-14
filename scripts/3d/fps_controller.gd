@tool
class_name FPSController extends BaseController

@export var JUMP_ACCEL = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	rotation.y = yaw
	camera_controller.rotation.x = pitch

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	var idir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var dir = (transform.basis * Vector3(idir.x, 0.0, idir.y)).normalized()
	var y_vel = velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward(MOVE_SPEED * dir, MOVE_ACCEL * delta)
	velocity.y = y_vel - GRAVITY * delta
	if is_on_floor() && Input.is_action_pressed("jump"):
		velocity.y += JUMP_ACCEL
	move_and_slide()
