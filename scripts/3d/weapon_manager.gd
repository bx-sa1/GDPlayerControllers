class_name WeaponManager extends Node3D

@export var weapon_list: Array[Weapon] = []
var current_weapon_id: int = -1

var cooldown: bool = false
var t_cooldown = 0
var just_fired = false
var exclude_ammos_from_cam_hit_test: Array[RID] = []

signal fire_hitscan_hit(weapon: Weapon, hit_pos: Vector3, collider: Node)
signal fire_projectile_hit(weapon: Weapon, hit_pos: Vector3, collider: Node)
signal fired(weapon: Weapon)
signal reloading(weapon: Weapon)
signal reloaded(weapon: Weapon)

func _ready() -> void:
	change_weapon(current_weapon_id)

func _process(delta: float) -> void:
	if Input.is_action_pressed("weapon_up"):
		change_weapon((current_weapon_id + 1) % len(weapon_list))
	if Input.is_action_pressed("weapon_down"):
		change_weapon((current_weapon_id - 1) % len(weapon_list))
	if weapon_list[current_weapon_id].auto:
		if Input.is_action_pressed("fire"):
			print("AutoFire")
			fire()
	else:
		if Input.is_action_just_pressed("fire"):
			print("No AutoFire")
			fire()

	weapon_list[current_weapon_id].update(delta)

func change_weapon(new_id: int) -> void:
	if new_id < 0 and new_id > len(weapon_list):
		return

	if current_weapon_id != -1:
		var current_weapon = weapon_list[current_weapon_id]
		current_weapon.deactivate()
		remove_child(current_weapon.scene_instance)

	var new_weapon = weapon_list[new_id]
	add_child(new_weapon.get_scene_instance())
	new_weapon.activate()
	current_weapon_id = new_id

func fire() -> void:
	var current_weapon: Weapon = weapon_list[current_weapon_id]
	if current_weapon.should_reload():
		current_weapon.reload()
	if not current_weapon.can_fire():
		return

	var ammount = current_weapon.fire()
	assert(ammount != -1)

	var camera = get_viewport().get_camera_3d()
	var viewport_size = get_viewport().get_size()

	var ray_origin = camera.project_ray_origin(viewport_size/2)
	var ray_dir = camera.project_ray_normal(viewport_size/2)

	for i in ammount:
		var spread_ray_dir = Quaternion.from_euler(Vector3(
			_calc_rand_spread_angle(current_weapon.spread),
			_calc_rand_spread_angle(current_weapon.spread),
			_calc_rand_spread_angle(current_weapon.spread))) * ray_dir

		var hit_point = camera_hit_test(current_weapon, ray_origin, spread_ray_dir)
		if current_weapon.type == Weapon.WeaponType.HITSCAN:
			fire_hitscan(current_weapon, hit_point)
		elif current_weapon.type == Weapon.WeaponType.PROJECTILE:
			fire_projectile(current_weapon, hit_point)

func camera_hit_test(weapon: Weapon, ray_origin: Vector3, ray_dir: Vector3) -> Vector3:
	var ray_end = ray_origin+ray_dir*weapon.fire_range
	var params = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	params.exclude = exclude_ammos_from_cam_hit_test
	var hit = get_world_3d().direct_space_state.intersect_ray(params)
	if hit != {}:
		return hit.position
	else:
		return ray_end


func fire_hitscan(hitscan: Weapon, camera_collision_point: Vector3):
	var inst = hitscan.get_scene_instance()
	var fire_origin = inst.global_transform.origin
	var fire_dir = (camera_collision_point - fire_origin).normalized()
	var params = PhysicsRayQueryParameters3D.create(fire_origin, camera_collision_point+fire_dir*2)
	var hit = get_world_3d().direct_space_state.intersect_ray(params)
	if hit != {}:
		fire_hitscan_hit.emit(hitscan, hit.position, hit.collider)
		add_decal_to_world(hitscan, hit.position)


func fire_projectile(projectile: Weapon, camera_collision_point: Vector3):
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
	exclude_ammos_from_cam_hit_test.push_back(ammo_rid)
	ammo.tree_exited.connect(_on_ammo_tree_exited.bind(ammo_rid))
	ammo.hit.connect(_on_ammo_hit)


func add_decal_to_world(weapon: Weapon, hitpos: Vector3):
	var decal = weapon.ammo_hit_decal.instantiate()
	get_tree().get_root().add_child(decal)
	decal.global_position = hitpos

func play_weapon_animation(weapon: Weapon, anim_name: String) -> void:
	if weapon.is_scenes_initialized():
		return

	var anim = weapon.scene_instance.get_node("AnimationPlayer")
	if anim != null:
		anim.play(anim_name)

func _calc_rand_spread_angle(spread: float) -> float:
	return randf_range(-deg_to_rad(spread), deg_to_rad(spread))


func _on_ammo_tree_exited(rid: RID):
	exclude_ammos_from_cam_hit_test.erase(rid)

func _on_ammo_hit(ammo: Ammo, body: Node):
	fire_projectile_hit.emit(ammo.from_weapon, ammo.global_position, body)
	add_decal_to_world(ammo.from_weapon, ammo.global_position)
