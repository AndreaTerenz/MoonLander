class_name Harbor
extends Area2D

@export
var target_path : NodePath = "Target"
@export
var start_enabled := true

@onready
var target := get_node(target_path)

var enabled : bool :
	get:
		return monitorable and monitoring
	set(val):
		monitorable = val
		monitoring = val

func _ready():
	enabled = start_enabled
	collision_layer *= 0
	collision_mask *= 0
	
	Utils.set_layer_bit_in_object(self, "Lander")
	Utils.set_mask_bit_in_object(self, "Lander")

	body_entered.connect(
		func (body):
			if body == Globals.lander:
				Globals.lander.enter_harbor(self)
	)

	body_exited.connect(
		func (body):
			if body == Globals.lander:
				Globals.lander.leave_harbor(self)
	)
