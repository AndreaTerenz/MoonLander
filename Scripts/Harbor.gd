class_name Harbor
extends Area2D

@export
var target : Node2D = $Target
@export
var start_enabled := true

var enabled : bool :
	get:
		return monitorable and monitoring
	set(val):
		monitorable = val
		monitoring = val

var lander_in := false

func _ready():
	enabled = start_enabled
	collision_layer *= 0
	collision_mask *= 0
	
	Utils.set_layer_bit_in_object(self, "Lander")
	Utils.set_mask_bit_in_object(self, "Lander")

	body_entered.connect(
		func (body):
			if body == Globals.lander:
				lander_in = true
				Globals.lander.enter_harbor(self)
	)

	body_exited.connect(
		func (body):
			if body == Globals.lander:
				lander_in = false
				Globals.lander.leave_harbor(self)
	)
	
func _input(event):
	if Input.is_action_just_pressed("dock") and lander_in:
		Globals.lander.start_docking(self)
