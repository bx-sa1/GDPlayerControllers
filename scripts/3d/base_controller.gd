class_name BaseController extends CharacterBody3D

# Modular script that handles player movement of a CharacterBody3D
# The character body must have a Camaera3D and a CollisionObject3D as a child



@export var MOVE_SPEED = 32
@export var MOVE_ACCEL = 10
@export var SENSITIVITY = 1.0
@export var GRAVITY_ACCEL = 98.1
@export var FRICTION = 0.05
@export var JUMP_STRENGTH = 25

var yaw = 0.0
var pitch = 0.0
var roll = 0.0


var ground_velocity: Vector3 = Vector3.ZERO
var vertical_velocity: Vector3 = Vector3.ZERO
var wish_dir: Vector3 = Vector3.ZERO

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_focus_mode"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event is InputEventMouseMotion:
		_look(event.relative * SENSITIVITY * 0.1)

func _process(_delta: float) -> void:
	wish_dir = _move_dir()
	# if is_moving():
	# 	print("moving")
	# elif is_stopping():
	# 	print("stopping")
	# elif is_falling():
	# 	print("falling")
	# elif is_jumping():
	# 	print("jumping")
	# else:
	# 	print("idle")

func _physics_process(delta: float) -> void:
	_friction(delta)
	_accelerate(wish_dir, delta)
	_gravity(delta)

	if is_jump_started():
		_jump(delta)


	velocity = ground_velocity + vertical_velocity
	move_and_slide()

# Controls camera movement
func _look(__input: Vector2) -> void:
	pass

# Returns a vector describe where to move based on key input
func _move_dir() -> Vector3:
	return Vector3.FORWARD

# Movement force
func _accelerate(move_dir: Vector3, delta: float) -> void:
	var currentspeed = ground_velocity.dot(move_dir)
	var addspeed = MOVE_SPEED - currentspeed
	if addspeed <= 0:
		return
	var accel = MOVE_ACCEL * MOVE_ACCEL * delta
	if accel > addspeed:
		accel = addspeed
	ground_velocity += accel*move_dir

func _friction(delta: float) -> void:
	var speed = ground_velocity.length()
	if speed < 1.0:
		ground_velocity = Vector3.ZERO
		return

	var drop = 0.0
	if is_on_floor:
		drop += speed * (FRICTION * GRAVITY_ACCEL)* delta

	var newspeed = speed - drop
	if newspeed < 0.0:
		newspeed = 0.0
	newspeed /= speed
	ground_velocity *= newspeed

# Gravity force
func _gravity(delta: float) -> void:
	if !is_on_floor():
		vertical_velocity += GRAVITY_ACCEL * -up_direction * delta
	else:
		vertical_velocity = Vector3.ZERO

func _jump(delta: float) -> void:
	vertical_velocity += GRAVITY_ACCEL * up_direction * JUMP_STRENGTH * delta

# Jump force opposing gravity force
func is_moving() -> bool:
	return wish_dir.length() > 0

func is_stopping() -> bool:
	return wish_dir.length() == 0 and ground_velocity.length() > 0

func is_jump_started() -> bool:
	return is_on_floor() && Input.is_action_pressed("jump")

func is_jumping() -> bool:
	return !is_on_floor() and up_direction.dot(vertical_velocity.normalized()) == 1

func is_falling() -> bool:
	return !is_on_floor() and up_direction.dot(vertical_velocity.normalized()) == -1
