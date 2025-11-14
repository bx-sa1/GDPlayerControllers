@tool
class_name BaseController extends CharacterBody3D

# Modular script that handles player movement of a CharacterBody3D
# The character body must have a Camaera3D and a CollisionObject3D as a child


var camera_controller: CameraController3D = null:
	set(val):
		camera_controller = val
		update_configuration_warnings()
var collision: CollisionShape3D = null:
	set(val):
		collision = val
		update_configuration_warnings()
var visual: VisualInstance3D = null:
	set(v):
		visual = v
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()

	if camera_controller == null:
		warnings.push_back("No CameraController3D child.")

	if collision == null:
		warnings.push_back("No CollisionShape3D child.")

	if visual == null:
		warnings.push_back("No node with VisualInstance3D subclass.")

	return warnings

@export var MOVE_SPEED = 2
@export var MOVE_ACCEL = 1
@export var SENSITIVITY = 1
@export var GRAVITY = 10
@export var CAPTURE_MOUSE = true

var yaw = 0.0
var pitch = 0.0
var roll = 0.0

func _enter_tree() -> void:
	for c in get_children():
		if camera_controller == null && c is CameraController3D:
			camera_controller = c
		elif collision == null && c is CollisionShape3D:
			collision = c
		elif visual == null && c is VisualInstance3D:
			visual = c

func _exit_tree() -> void:
	for c in get_children():
		if camera_controller != null && c is CameraController3D:
			camera_controller = c
		elif collision != null && c is CollisionShape3D:
			collision = null
		elif visual != null && c is VisualInstance3D:
			visual = null


func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return

	if event is InputEventMouseMotion:
		yaw += deg_to_rad(-event.relative.x * 0.1 * SENSITIVITY)
		pitch += deg_to_rad(-event.relative.y * 0.1 * SENSITIVITY)
		pitch = clampf(pitch, -PI/2, PI/2)
	else:
		if event.is_action_pressed("ui_focus_mode"):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		elif event.is_action_pressed("ui_cancel"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
