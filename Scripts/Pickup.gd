class_name Pickup
extends Area2D

@export var amount := 1.


func _ready():
	collision_layer = 0
	collision_mask = 0
	
	set_collision_layer_value(3, true)
	set_collision_mask_value(2, true)

	body_entered.connect(
		func (body):
			if body is Lander:
				_on_entered(body)
				queue_free()
	)

func _on_entered(lander: Lander):
	pass
