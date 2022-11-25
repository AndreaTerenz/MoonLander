class_name LanderEngine
extends Node2D

enum ENGINE_MODE {
	SOLID = 0,
	LIQUID = 1
}

@onready var db_tex := $"DB tex"

@export_enum("SOLID", "LIQUID") var mode : int = ENGINE_MODE.LIQUID
@export var max_thrust := 100.0
@export var action := ""
@export_range(0., 1., .0001) var acceleration := .6

var parent_ship : Lander = null
var current_thrust := 0.

func _ready():
	if get_parent() is Lander:
		parent_ship = get_parent()
		db_tex.look_at(parent_ship.global_position)
		
func get_thrust():
	if mode == ENGINE_MODE.SOLID:
		if Input.is_action_just_pressed(action) or current_thrust != 0.:
			return max_thrust
	elif mode == ENGINE_MODE.LIQUID:
		if Input.is_action_pressed(action):
			return lerpf(current_thrust, max_thrust, acceleration)
		elif Input.is_action_just_released(action):
			return 0.
	
	return 0.

func _process(delta):
	if action != "":
		var offset = parent_ship.global_position - self.global_position
		var thrust_vector = offset.normalized()
		
		current_thrust = get_thrust()
		parent_ship.apply_force(thrust_vector * current_thrust, offset)
		db_tex.visible = (current_thrust != 0.)
