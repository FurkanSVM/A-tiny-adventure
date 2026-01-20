extends Area2D
signal got_hit

@onready var sprite_2d: Sprite2D = $Sprite2D

const speed = 180
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		emit_signal("got_hit")

func _process(delta: float) -> void:
	if self.scale.x == -1:
		position.x += delta * speed 
	else:
		position.x -= delta * speed
