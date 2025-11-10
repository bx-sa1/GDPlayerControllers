@tool
class_name FPSController extends BaseController

@export var MAX_SPEED = 2
@export var SENSITIVITY = 1
@export var GRAVITY = 10
@export var JUMP_ACCEL = 5
@export var CAM_DISTANCE = 10.0

enum ViewState {
	FirstPerson,
	ThirdPerson
	}
@export var view_state: ViewState:
	set(v):
		view_state = v
		view_state_change.emit(v)
signal view_state_change

var pitch = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	view_state_change.connect(on_view_state_change)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	if is_on_floor() && Input.is_action_pressed("jump"):
		velocity.y += JUMP_ACCEL

	var idir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var dir = (transform.basis * Vector3(idir.x, 0.0, idir.y)).normalized()
	velocity.x = dir.x * MAX_SPEED
	velocity.z = dir.z * MAX_SPEED

	move_and_slide()


func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return

	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * 0.1 * SENSITIVITY))

		if view_state == ViewState.FirstPerson:
			camera.rotate_x(deg_to_rad(-event.relative.y * 0.1 * SENSITIVITY))
			camera.rotation.x = clampf(camera.rotation.x, -PI/2, PI/2)
		elif view_state == ViewState.ThirdPerson:
			pitch += deg_to_rad(-event.relative.y * 0.1 * SENSITIVITY)
			pitch = clampf(pitch, -PI/2, PI/2)
			camera.position.x = cos(pitch) * CAM_DISTANCE
			camera.position.y = sin(pitch) * CAM_DISTANCE
			camera.position.z = cos(pitch) * CAM_DISTANCE
			camera.look_at(position)

func on_view_state_change(v: ViewState) -> void:
	if v == ViewState.FirstPerson:
		camera.position = Vector3.ZERO
	elif v == ViewState.ThirdPerson:
		camera.position.z -= CAM_DISTANCE
