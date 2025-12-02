class_name Ammo extends RigidBody3D

signal hit(body: Node)

var from_weapon: Weapon

func _ready() -> void:
	body_entered.connect(_on_ammo_body_entered)

func _on_ammo_body_entered(body: Node):
	hit.emit(self, body)
	queue_free()
