class_name WalkComponent extends CharacterComponent

@export var move_speed = 32
@export var move_accel = 10
@export var jump_strength = 0.3

func _init_always_active() -> bool:
	return true

func apply(delta: float, velocity: Velocity, wishdir: Vector3, forward: Vector3, updir: Vector3, is_on_floor: bool, is_on_wall: bool) -> Velocity:
	velocity = _accelerate(velocity, wishdir, delta)
	return velocity

func _accelerate(velocity: Velocity, move_dir: Vector3, delta: float) -> Velocity:
	var currentspeed = velocity.horizontal.dot(move_dir)
	var addspeed = move_speed - currentspeed
	if addspeed <= 0:
		return velocity
	var accel = move_speed * move_accel * delta
	if accel > addspeed:
		accel = addspeed
	velocity.horizontal += accel*move_dir
	return velocity
