class_name CharacterController extends CharacterBody3D

@export var debug = false
@export_category("References")
@export var camera_controller: CameraController
@export var visual: Node3D
@export var collision: CollisionShape3D
@export_category("Settings")
@export var strafe: bool = true
@export var max_step_height: float = 0.2
@export_category("Components")
@export var components: Array[CharacterComponent]

var _velocity := Velocity.new()
var _forward := Vector3.ZERO
var _last_forward := Vector3.ZERO

const MIN_STEP_HEIGHT := 0.1

func move(delta: float, input_axis := Vector2.ZERO) -> void:
	var wishdir = (camera_controller.global_basis * Vector3(input_axis.x, 0.0, input_axis.y)).normalized()
	wishdir = _project_ground_plane(wishdir)
	_forward = _calc_forward(wishdir)

	for component in components:
		if component.is_active():
			_velocity = component.apply(delta, _velocity, wishdir, _forward, up_direction, is_on_floor(), is_on_wall())
	velocity = _velocity.sum()
	move_and_slide()

	if is_on_floor():
		_handle_step()

	var visual_forward = visual.global_basis.z
	var target_angle := visual_forward.signed_angle_to(_forward, up_direction)
	visual.rotate(up_direction, target_angle)


func _handle_step():
	for i in get_slide_collision_count():
		var slide_collision := get_slide_collision(i)
		if not _is_collision_wall(slide_collision):
			continue
		var step_height = _get_step_height(slide_collision)
		if step_height > MIN_STEP_HEIGHT and step_height <= max_step_height:
			if debug:
				print("Step Found: Height = ", step_height)
			global_position += up_direction * step_height
		else:
			print("\"Step\" too high: Height = ", step_height)


func _is_collision_wall(col: KinematicCollision3D) -> bool:
	if col.get_angle(0, up_direction) <= floor_max_angle:
			return _check_collision_is_wall(col)
	return true

func _check_collision_is_wall(col: KinematicCollision3D) -> bool:
	var bottom = _get_bottom()
	var a = _vector_from_bottom_to_collision_point_projected_on_ground_plane(bottom, col)

	var params = PhysicsRayQueryParameters3D.create(bottom, bottom + a)
	params.collision_mask = self.collision_mask
	params.exclude = [self.get_rid()]

	var hit = get_world_3d().direct_space_state.intersect_ray(params)
	if hit and hit.normal.angle_to(up_direction) > floor_max_angle:
		return true

	return false

func _get_bottom() -> Vector3:
	var a = collision.global_position + -up_direction*collision.shape.height/2
	a += up_direction*0.01
	return a

func _get_top() -> Vector3:
	var a = collision.global_position + up_direction*collision.shape.height/2
	return a

func _get_step_height(col: KinematicCollision3D) -> float:
	var top = _get_top()
	var bottom = _get_bottom()
	var a = _vector_from_bottom_to_collision_point_projected_on_ground_plane(bottom, col)
	var from = top + a
	var to = bottom + a
	var params = PhysicsRayQueryParameters3D.create(from, to)
	var intersect = get_world_3d().direct_space_state.intersect_ray(params)
	if intersect:
		return (to - intersect.position).length()
	return 0.0


func _vector_from_bottom_to_collision_point_projected_on_ground_plane(bottom: Vector3, col: KinematicCollision3D) -> Vector3:
	var a = col.get_position() - bottom
	a = a - a.project(up_direction)
	return a

func _project_ground_plane(v: Vector3) -> Vector3:
	return (v - v.project(up_direction)).normalized()

func _calc_forward(wishdir: Vector3) -> Vector3:
	if strafe:
		return _project_ground_plane(-camera_controller.global_basis.z)
	else:
		if wishdir.length() > 0:
			_last_forward = wishdir
		return _last_forward
