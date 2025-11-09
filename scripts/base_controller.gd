@tool
class_name BaseController extends CharacterBody3D

# Modular script that handles player movement of a CharacterBody3D
# The character body must have a Camaera3D and a CollisionObject3D as a child

var camera: Camera3D = null:
	set(val):
		camera = val
		update_configuration_warnings()
var collision: CollisionShape3D = null:
	set(val):
		collision = val
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()

	if camera == null:
		warnings.push_back("No Camera3D child")

	if collision == null:
		warnings.push_back("No CollisionShape3D child")

	return warnings

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("child_entered_tree", _on_child_entered_tree)
	connect("child_exiting_tree", _on_child_exiting_tree)

func _on_child_entered_tree(n: Node) -> void:
	if camera == null && n is Camera3D:
		camera = n
	elif collision == null && n is CollisionShape3D:
		collision = n

func _on_child_exiting_tree(n: Node) -> void:
	if camera != null && n is Camera3D:
		camera = null
	elif collision != null && n is CollisionShape3D:
		collision = null
