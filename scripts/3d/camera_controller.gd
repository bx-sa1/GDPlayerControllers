class_name CameraController3D extends SpringArm3D

var camera: Camera3D = null:
	set(v):
		camera = v
		update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()

	if camera == null:
		warnings.push_back("No Camera3D child")

	return warnings


func _enter_tree() -> void:
	for c in get_children():
		if camera == null and c is Camera3D:
			camera = c

func _exit_tree() -> void:
	for c in get_children():
		if camera != null and c is Camera3D:
			camera = null
