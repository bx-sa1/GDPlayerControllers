class_name FPSController extends BaseController

@export var camera_pivot: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	super(event)
	if event is InputEventMouseMotion:
		self.basis = Basis(self.basis.y.normalized(), deg_to_rad(-event.relative.x * SENSITIVITY)) * self.basis
		camera_pivot.basis = Basis(camera_pivot.basis.x.normalized(), deg_to_rad(-event.relative.y * SENSITIVITY)) * camera_pivot.basis
		camera_pivot.rotation.x = clampf(camera_pivot.rotation.x, -PI/2, PI/2)

func _physics_process(delta: float) -> void:
	var idir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var dir = (global_basis * Vector3(idir.x, 0.0, idir.y)).normalized()
	friction(delta)
	accelerate(dir, delta)
	gravity(delta)
	jump(delta)
	move_and_slide()
