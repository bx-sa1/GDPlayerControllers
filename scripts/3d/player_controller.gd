class_name PlayerController extends CharacterBody3D

# Modular script that handles player movement of a CharacterBody3D
# The character body must have a Camaera3D and a CollisionObject3D as a child

enum ControllerType { FIRST_PERSON, THIRD_PERSON, PLATFORMER }

@export var weapon_manager: WeaponManager:
	set(v):
		weapon_manager = v
		if v != null:
			pass
@export var camera_manager: CameraManager:
	set(v):
		camera_manager = v
		if v != null:
			v.yawed.connect(_on_camera_manager_yawed)
			v.pitched.connect(_on_camera_manager_pitched)
@export var visual: Node3D

@export var MOVE_SPEED = 32
@export var MOVE_ACCEL = 10
@export var GRAVITY_ACCEL = 98.1
@export var FRICTION = 0.05
@export var JUMP_STRENGTH = 25
@export var TURN_SPEED = 30 # USed only form PLATFORMER type
@export var TYPE: ControllerType:
	set(v):
		TYPE = v
		if is_node_ready():
			update_camera_manager_spring_length()

var original_camera_manager_spring_length
var last_move_dir = Vector3.FORWARD
var ground_velocity: Vector3 = Vector3.ZERO
var vertical_velocity: Vector3 = Vector3.ZERO
var wish_dir: Vector3 = Vector3.ZERO

func _ready() -> void:
	self.original_camera_manager_spring_length = camera_manager.spring_length
	update_camera_manager_spring_length()

func _process(delta: float) -> void:
	wish_dir = _move_dir()
	if TYPE == ControllerType.PLATFORMER:
		var visual_target_angle = Vector3.FORWARD.signed_angle_to(self.last_move_dir, Vector3.UP)
		self.visual.global_rotation.y = lerp_angle(self.visual.rotation.y, visual_target_angle, TURN_SPEED * delta)

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

# Returns a vector describe where to move based on key input
func _move_dir() -> Vector3:
	var idir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var dir: Vector3
	match TYPE:
		ControllerType.FIRST_PERSON, ControllerType.THIRD_PERSON:
			dir = (self.global_basis * Vector3(idir.x, 0.0, idir.y)).normalized()
		ControllerType.PLATFORMER:
			dir = (self.camera_manager.camera.global_basis * Vector3(idir.x, 0.0, idir.y)).normalized()
			dir.y = 0.0
			dir = dir.normalized()
			if dir.length() > 0.0:
				last_move_dir = dir

	return dir


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

func update_camera_manager_spring_length() -> void:
	if camera_manager == null:
		return

	match TYPE:
		ControllerType.FIRST_PERSON:
			camera_manager.spring_length = 0.0
		ControllerType.THIRD_PERSON, ControllerType.PLATFORMER:
			camera_manager.spring_length = original_camera_manager_spring_length


func _on_camera_manager_yawed(yaw: float):
	match TYPE:
		ControllerType.FIRST_PERSON, ControllerType.THIRD_PERSON:
			self.basis = Basis(self.basis.y.normalized(), yaw) * self.basis
		ControllerType.PLATFORMER:
			self.camera_manager.basis = Basis(self.camera_manager.basis.y.normalized(), yaw) * self.camera_manager.basis

func _on_camera_manager_pitched(pitch: float):
	self.camera_manager.basis = Basis(self.camera_manager.basis.x.normalized(), pitch) * self.camera_manager.basis
	if weapon_manager != null:
		self.weapon_manager.basis = Basis(self.weapon_manager.basis.x.normalized(), pitch) * self.weapon_manager.basis

	self.camera_manager.rotation.x = clampf(self.camera_manager.rotation.x, -PI/2, PI/2)
	self.weapon_manager.rotation.x = clampf(self.weapon_manager.rotation.x, -PI/2, PI/2)
