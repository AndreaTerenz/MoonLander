class_name LanderEngine
extends LanderModule

signal out_of_fuel

enum ENGINE_MODE {
	SOLID = 0,
	LIQUID = 1
}

@onready var thrust_target := %ThrustTarget
@onready var db_tex := $"DB tex"

@export var action := ""

@export_group("Thrust")
@export_enum("SOLID", "LIQUID") var mode : int = ENGINE_MODE.LIQUID
@export var thrust_vec_override := Vector2.ZERO
@export var max_thrust := 100.0
@export_range(0., 1., .0001) var acceleration := .6

@export_group("Fuel")
@export var tank_capacity := 4000
# max units of fuel consumed per second
@export var max_tank_consumption := 1.

var thrust_ratio := 0.
var tank_level = tank_capacity
var tank_level_ratio :
	get:
		return tank_level/tank_capacity
var tank_level_missing :
	get:
		return tank_capacity-tank_level

func setup(p: Lander):
	super.setup(p)
	
	parent_ship.add_engine(self)
	
	db_tex.look_at(parent_ship.global_position)
	
	if thrust_vec_override != Vector2.ZERO:
		thrust_target.translate(thrust_vec_override)
	else:
		thrust_target.global_position = parent_ship.global_position
		
func get_thrust_ratio():
	if mode == ENGINE_MODE.SOLID:
		if Input.is_action_just_pressed(action) or thrust_ratio != 0.:
			return 1.
	elif mode == ENGINE_MODE.LIQUID:
		if Input.is_action_pressed(action):
			return lerpf(thrust_ratio, 1., acceleration)
		elif Input.is_action_just_released(action):
			return 0.
	
	return 0.
	
func can_run():
	return (action != "") and tank_level > 0 and enabled

func _process(delta):
	var e := can_run()
	
	if e:
		var offset = parent_ship.global_position - self.global_position
		var thrust_vector = (thrust_target.global_position - self.global_position).normalized()
		
		thrust_ratio = get_thrust_ratio()
		
		var thrust = thrust_ratio * max_thrust
		parent_ship.apply_force(thrust_vector * thrust, offset)
		
		var consumption = thrust_ratio * max_tank_consumption
		tank_level -= consumption
		
		if tank_level <= 0.:
			out_of_fuel.emit()
		
	db_tex.look_at(thrust_target.global_position)
	db_tex.visible = thrust_ratio != 0. and e

func capacity_str():
	return "%.2f %%" % [tank_level_ratio*100.]
