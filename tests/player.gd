extends CharacterController

@export var weapon_controller: WeaponController
@export var jump_component: JumpComponent

func _ready() -> void:
	jump_component.active_p = func(): return self.is_on_floor() and Input.is_action_just_pressed("jump")

func _process(delta: float) -> void:
	if weapon_controller.is_weapon_up_pressed():
		weapon_controller.change_weapon(weapon_controller.current_weapon_id + 1)
	if weapon_controller.is_weapon_down_pressed():
		weapon_controller.change_weapon(weapon_controller.current_weapon_id - 1)
	if weapon_controller.is_fire_pressed():
		weapon_controller.fire()

func _physics_process(delta: float) -> void:
	var idir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	move(delta, idir)
