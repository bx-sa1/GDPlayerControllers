@tool
class_name FPSController extends BaseController


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
	friction(delta)
	accelerate(dir, delta)
	gravity(delta)
	jump(delta)
	move_and_slide()
