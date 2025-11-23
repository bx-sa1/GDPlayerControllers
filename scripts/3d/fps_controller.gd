class_name FPSController extends BaseController

@export var camera_pivot: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation.y = yaw
	camera_pivot.rotation.x = pitch

func _physics_process(delta: float) -> void:
	var idir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var dir = (transform.basis * Vector3(idir.x, 0.0, idir.y)).normalized()
	friction(delta)
	accelerate(dir, delta)
	gravity(delta)
	jump(delta)
	move_and_slide()
