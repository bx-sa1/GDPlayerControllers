class_name CameraManager extends SpringArm3D

@export var camera: Camera3D

@export var SENSITIVITY: float = 1.0

var yaw
var pitch

signal yawed(yaw: float)
signal pitched(pitch: float)

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion:
		yawed.emit(deg_to_rad(-event.relative.x * SENSITIVITY * 0.1))
		pitched.emit(deg_to_rad(-event.relative.y * SENSITIVITY * 0.1))
