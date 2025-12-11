class_name GravityComponent extends CharacterComponent

@export var gravity_accel = 98.1
@export var friction = 0.05

func _init_always_active() -> bool:
	return true

func apply(delta: float, velocity: Velocity, wishdir: Vector3, forward: Vector3, updir: Vector3, is_on_floor: bool, is_on_wall: bool) -> Velocity:
	if not is_on_floor:
		velocity.vertical += gravity_accel * -updir * delta
	else:
		velocity.vertical = Vector3.ZERO
	velocity = _friction(is_on_floor, velocity, delta)
	return velocity

func _friction(is_on_floor: bool, velocity: Velocity, delta: float) -> Velocity:
	var speed = velocity.horizontal.length()
	if speed < 1.0:
		velocity.horizontal = Vector3.ZERO
		return velocity

	var drop = 0.0
	if is_on_floor:
		drop += speed * (friction * gravity_accel) * delta

	var newspeed = speed - drop
	if newspeed < 0.0:
		newspeed = 0.0
	newspeed /= speed
	velocity.horizontal *= newspeed
	return velocity
