class_name Weapon extends Resource

enum WeaponType { PROJECTILE, HITSCAN }
@export var name: String
@export var scene: PackedScene
@export var ammo_scene: PackedScene
@export var ammo_hit_decal: PackedScene

@export_category("Stats")
@export var type: WeaponType
@export var max_ammo_count: int
# How fast the ammunition moves, only realy useful for projectile weapons
@export var ammo_speed: float
# How many ammunitions to fire at once
@export var fire_ammount: int
# How far ammunitions can go
@export var fire_range: float
# How many times you can shoot per second
@export var fire_rate: float
@export var spread: float
@export var auto: bool
@export var damage: float
@export var reload_time: float

var ammo_count: int = max_ammo_count
var cooldown: bool = false
var t_cooldown: float
var reloading: bool = false
var t_reloading: float

var scene_instance: Node3D

signal coolingdown(weapon: Weapon)
signal reloaded(weapon: Weapon)
signal fired(weapon: Weapon)

func get_scene_instance() -> Node3D:
	if scene_instance == null:
		scene_instance = scene.instantiate()
	return scene_instance

func is_coolingdown() -> bool:
	return cooldown

func reload() -> void:
	if scene_instance.is_inside_tree():
		reloading = true

func should_reload() -> bool:
	return ammo_count == 0

func is_reloading() -> bool:
	return reloading

func fire() -> int: # return how much is acctually fire
	if scene_instance.is_inside_tree():
		ammo_count -= fire_ammount
		cooldown = true
		if ammo_count < 0:
			ammo_count = 0
			fired.emit(self)
			return fire_ammount - ammo_count
		else:
			return fire_ammount
	else:
		return -1

func can_fire() -> bool:
	return cooldown == false and reloading == false

func update(delta: float) -> void:
	if should_reload():
		reload()
	if cooldown:
		t_cooldown += delta
		if t_cooldown >= 1.0/fire_rate:
			cooldown = false
			t_cooldown = 0
			coolingdown.emit(self)
	if reloading:
		t_reloading += delta
		if t_reloading >= reload_time:
			ammo_count = max_ammo_count
			reloading = false
			t_reloading = 0
			reloaded.emit(self)

func get_handle_marker() -> Marker3D:
	var marker = get_scene_instance().get_node("handle_marker")
	return marker
