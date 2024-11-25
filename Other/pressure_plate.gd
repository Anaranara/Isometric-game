extends Area3D
@onready var sprite = $MeshInstance3D/AnimationPlayer

func _ready() -> void:
	sprite.play("nonpressed")

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("trigger"):
		sprite.play("pressed")

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("trigger"):
		sprite.play("nonpressed")
