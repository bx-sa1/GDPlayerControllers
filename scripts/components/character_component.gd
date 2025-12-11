class_name CharacterComponent extends Node

@export var always_active = _init_always_active()
@export var default_active = _init_default_active()
var active_p: Callable = Callable()

func is_active():
	if always_active:
		return true
	if active_p.is_valid():
		return active_p.call()
	return default_active

func apply(delta: float, velocity: Velocity, wishdir: Vector3, forward: Vector3, updir: Vector3, is_on_floor: bool, is_on_wall: bool) -> Velocity:
	return velocity

func _init_always_active() -> bool:
	return false

func _init_default_active() -> bool:
	return true
