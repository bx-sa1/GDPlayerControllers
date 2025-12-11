class_name CameraController extends Node3D

@export_category("Settings")
@export var SENSITIVITY: float = 1.0
@export_range(0, 90) var pitch_lower_limit: float = 89
@export_range(0, 90) var pitch_upper_limit: float = 89

var _yaw: float
var _pitch: float

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion:
		_yaw += -event.relative.x * SENSITIVITY * 0.1
		_pitch += -event.relative.y * SENSITIVITY * 0.1
		_pitch = clampf(_pitch, -pitch_lower_limit, pitch_upper_limit)

func _process(delta: float) -> void:
	var camera_rotation = Vector3(deg_to_rad(_pitch), deg_to_rad(_yaw), 0)
	# var player_rotation = Vector3(0, deg_to_rad(_yaw), 0)

	transform.basis = Basis.from_euler(camera_rotation)
	# owner.basis = Basis.from_euler(player_rotation)
