class_name BaseController extends CharacterBody3D

# Modular script that handles player movement of a CharacterBody3D
# The character body must have a Camaera3D and a CollisionObject3D as a child



@export var MOVE_SPEED = 32
@export var MOVE_ACCEL = 10
@export var SENSITIVITY = 1.0
@export var GRAVITY_ACCEL = Vector3(0, -98.1, 0)
@export var GROUND_FRICTION = 0.05
@export var AIR_FRICTION = 0.04
@export var JUMP_STRENGTH = 25

var yaw = 0.0
var pitch = 0.0
var roll = 0.0


var move_velocity: Vector3 = Vector3.ZERO
var gravity_velocity: Vector3 = Vector3.ZERO

enum PlayerState {
	IDLE,
	MOVING,
	STOPPING,
	JUMPING,
	FALLING
	}
var player_state: PlayerState = PlayerState.IDLE

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_focus_mode"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event is InputEventMouseMotion:
		_look(event.relative * SENSITIVITY * 0.1)

func _physics_process(delta: float) -> void:
	var move_dir = _move_dir()
	_friction(delta)
	_accelerate(move_dir, delta)
	_gravity(delta)
	_jump(delta)
	velocity = move_velocity + gravity_velocity
	print(velocity.length())
	move_and_slide()

# Controls camera movement
func _look(__input: Vector2) -> void:
	pass

# Returns a vector describe where to move based on key input
func _move_dir() -> Vector3:
	return Vector3.FORWARD

# Movement force
func _accelerate(move_dir: Vector3, delta: float) -> void:
	var currentspeed = velocity.dot(move_dir)
	var addspeed = MOVE_SPEED - currentspeed
	if addspeed <= 0:
		return
	var accel = MOVE_ACCEL * MOVE_ACCEL * delta
	if accel > addspeed:
		accel = addspeed
	move_velocity += accel*move_dir
	player_state = PlayerState.MOVING

func _friction(delta: float) -> void:
	var speed = velocity.length()
	if speed < 0.01:
		player_state = PlayerState.IDLE
		velocity = Vector3.ZERO
		return

	var u = 0.0
	if is_on_floor():
		u = GROUND_FRICTION
	else:
		u = AIR_FRICTION
	var drop = speed * (u * GRAVITY_ACCEL.length())* delta
	var newspeed = speed - drop
	if newspeed < 0.0:
		newspeed = 0.0
	newspeed /= speed
	move_velocity *= newspeed
	player_state = PlayerState.STOPPING

# Gravity force
func _gravity(delta: float) -> void:
	if !is_on_floor():
		gravity_velocity += GRAVITY_ACCEL * delta
		player_state = PlayerState.FALLING
	else:
		gravity_velocity = Vector3.ZERO

# Jump force opposing gravity force
func _jump(delta: float) -> void:
	if is_on_floor() && Input.is_action_pressed("jump"):
		gravity_velocity += -GRAVITY_ACCEL * JUMP_STRENGTH * delta
		player_state = PlayerState.JUMPING
