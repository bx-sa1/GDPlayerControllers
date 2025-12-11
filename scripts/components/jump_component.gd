class_name JumpComponent extends CharacterComponent

@export var gravity_component: GravityComponent
@export var jump_strength: float = 0.3

func apply(delta: float, velocity: Velocity, wishdir: Vector3, forward: Vector3, updir: Vector3, is_on_floor: bool, is_on_wall: bool) -> Velocity:
	velocity.vertical = jump_strength * gravity_component.gravity_accel * updir
	return velocity
