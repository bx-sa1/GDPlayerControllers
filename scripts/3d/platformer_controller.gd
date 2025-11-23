class_name PlatformerController extends BaseController

@export var camera_pivot: Node3D
@export var camera: Camera3D
@export var visual: VisualInstance3D
@export var TURN_SPEED = 30

var last_move_dir = Vector3.FORWARD

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	super(event)
	if event is InputEventMouseMotion:
		camera_pivot.basis = Basis(camera_pivot.basis.y.normalized(), deg_to_rad(-event.relative.x * SENSITIVITY)) * camera_pivot.basis
		camera_pivot.basis = Basis(camera_pivot.basis.x.normalized(), deg_to_rad(-event.relative.y * SENSITIVITY)) * camera_pivot.basis
		camera_pivot.rotation.x = clampf(camera_pivot.rotation.x, -PI/2, PI/2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	camera_pivot.rotation.y = yaw
	camera_pivot.rotation.x = pitch

func _physics_process(delta: float) -> void:
	var idir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var dir = (camera.global_basis * Vector3(idir.x, 0.0, idir.y)).normalized()
	dir.y = 0.0
	dir = dir.normalized()
	friction(delta)
	accelerate(dir, delta)
	gravity(delta)
	jump(delta)

	move_and_slide()

	if dir.length() > 0.0:
		last_move_dir = dir
	var visual_target_angle = Vector3.FORWARD.signed_angle_to(last_move_dir, Vector3.UP)
	visual.global_rotation.y = lerp_angle(visual.rotation.y, visual_target_angle, TURN_SPEED * delta)
