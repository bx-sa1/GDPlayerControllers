class_name WeaponController extends Node3D

@export_category("Key Actions")
@export var weapon_up_action: String = "weapon_up"
@export var weapon_down_action: String = "weapon_down"
@export var fire_action: String = "fire"
@export_category("Settings")
@export_flags_3d_physics var ray_collision_mask = 1
@export var parent_node: Node
@export var weapon_list: Array[Weapon] = []
@export var fire_from_center_of_screen = false

var current_weapon_id: int = -1
var _exclude_ammos_from_cam_hit_test: Array[RID] = []

signal hit(weapon: Weapon, hit_pos: Vector3, collider: Node)
signal weapon_changed(old_weapon: Weapon, new_weapon: Weapon)

func _ready() -> void:
	change_weapon(0)

func _process(delta: float) -> void:
	weapon_list[current_weapon_id].update(delta)

func is_weapon_up_pressed() -> bool:
	return Input.is_action_just_pressed(weapon_up_action)

func is_weapon_down_pressed() -> bool:
	return Input.is_action_just_pressed(weapon_down_action)

func is_fire_pressed() -> bool:
	if weapon_list[current_weapon_id].auto:
		return Input.is_action_just_pressed(fire_action)
	else:
		return Input.is_action_pressed(fire_action)

func change_weapon(new_id: int) -> void:
	if new_id < 0:
		new_id = len(weapon_list) - 1
	elif new_id >= len(weapon_list):
		new_id = 0

	var current_weapon = weapon_list[current_weapon_id] if current_weapon_id != -1 else null
	var new_weapon = weapon_list[new_id]
	weapon_changed.emit(current_weapon, new_weapon)

	if current_weapon != null:
		parent_node.remove_child(current_weapon.get_scene_instance())

	parent_node.add_child(new_weapon.get_scene_instance())
	current_weapon_id = new_id

func fire() -> void:
	var weapon = get_current_weapon()
	if weapon.should_reload():
		weapon.reload()
	if not weapon.can_fire():
		return

	var ammount = weapon.fire()
	assert(ammount != -1)

	var ray_origin: Vector3
	var ray_dir: Vector3
	if fire_from_center_of_screen:
		var camera = get_viewport().get_camera_3d()
		var viewport_size = get_viewport().get_size()
		ray_origin = camera.project_ray_origin(viewport_size/2)
		ray_dir = camera.project_ray_normal(viewport_size/2)
	else:
		ray_origin = weapon.get_scene_instance().global_position
		ray_dir = weapon.get_scene_instance().global_basis.z

	for i in ammount:
		var spread_ray_dir = Quaternion.from_euler(Vector3(
			_calc_rand_spread_angle(weapon.spread),
			_calc_rand_spread_angle(weapon.spread),
			_calc_rand_spread_angle(weapon.spread))) * ray_dir

		var hit_point = _camera_hit_test(weapon, ray_origin, spread_ray_dir)
		if weapon.type == Weapon.WeaponType.HITSCAN:
			_fire_hitscan(weapon, hit_point)
		elif weapon.type == Weapon.WeaponType.PROJECTILE:
			_fire_projectile(weapon, hit_point)

func _camera_hit_test(weapon: Weapon, ray_origin: Vector3, ray_dir: Vector3) -> Vector3:
	var ray_end = ray_origin+ray_dir*weapon.fire_range
	var params = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	params.exclude = _exclude_ammos_from_cam_hit_test
	params.collision_mask = ray_collision_mask
	var intersect = get_world_3d().direct_space_state.intersect_ray(params)
	if intersect != {}:
		return intersect.position
	else:
		return ray_end


func _fire_hitscan(hitscan: Weapon, camera_collision_point: Vector3):
	var inst = hitscan.get_scene_instance()
	var fire_origin = inst.global_transform.origin
	var fire_dir = (camera_collision_point - fire_origin).normalized()
	var params = PhysicsRayQueryParameters3D.create(fire_origin, camera_collision_point+fire_dir*2)
	params.collision_mask = ray_collision_mask
	var intersect = get_world_3d().direct_space_state.intersect_ray(params)
	if intersect != {}:
		hit.emit(hitscan, intersect.position, intersect.collider)
		_add_decal_to_world(hitscan, intersect.position, intersect.normal)


func _fire_projectile(projectile: Weapon, camera_collision_point: Vector3):
	var ammo = projectile.ammo_scene.instantiate()
	if not ammo is Ammo:
		print("Ammo is not Ammo type")
		return

	var inst = projectile.get_scene_instance()
	var fire_origin = inst.global_transform.origin
	var fire_dir = (camera_collision_point - fire_origin).normalized()

	add_child(ammo)
	var ammo_rid = ammo.get_rid()
	ammo.from_weapon = projectile
	ammo.set_linear_velocity(fire_dir * projectile.ammo_speed)
	_exclude_ammos_from_cam_hit_test.push_back(ammo_rid)
	ammo.tree_exited.connect(_on_ammo_tree_exited.bind(ammo_rid))
	ammo.hit.connect(_on_ammo_hit)


func _add_decal_to_world(weapon: Weapon, hitpos: Vector3, hitnormal: Vector3):
	var decal: Node3D = weapon.ammo_hit_decal.instantiate()
	get_tree().get_root().add_child(decal)

	decal.global_position = hitpos + hitnormal * 0.01
	var decal_rotation = Quaternion(decal.global_basis.z, hitnormal)
	decal.quaternion *= decal_rotation

func _calc_rand_spread_angle(spread: float) -> float:
	return randf_range(-deg_to_rad(spread), deg_to_rad(spread))


func _on_ammo_tree_exited(rid: RID):
	_exclude_ammos_from_cam_hit_test.erase(rid)

func _on_ammo_hit(ammo: Ammo, body: Node):
	hit.emit(ammo.from_weapon, ammo.global_position, body)
	_add_decal_to_world(ammo.from_weapon, ammo.global_position, body.global_basis.z)

func get_current_weapon() -> Weapon:
	return weapon_list[current_weapon_id]
