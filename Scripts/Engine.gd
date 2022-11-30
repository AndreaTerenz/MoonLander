class_name LanderEngine
extends Node2D

signal out_of_fuel

enum ENGINE_MODE {
	SOLID = 0,
	LIQUID = 1
}

@onready var thrust_target := %ThrustTarget
@onready var db_tex := $"DB tex"

@export var enabled := true
@export_enum("SOLID", "LIQUID") var mode : int = ENGINE_MODE.LIQUID
@export var thrust_vec_override := Vector2.ZERO
@export var max_thrust := 100.0
@export var action := ""
@export var tank_capacity := 4000
# max units of fuel consumed per second
@export var tank_max_consumption := 1.
@export_range(0., 1., .0001) var acceleration := .6

var parent_ship : Lander = null
var current_thrust_ratio := 0.
var current_tank_level = tank_capacity

func _ready():
	var p = get_parent()
	
	if p is Lander:
		await p.ready
		
		parent_ship = p
		parent_ship.add_engine(self)
		
		db_tex.look_at(parent_ship.global_position)
		
		if thrust_vec_override != Vector2.ZERO:
			thrust_target.translate(thrust_vec_override)
		else:
			thrust_target.global_position = parent_ship.global_position
		
func get_thrust_ratio():
	if mode == ENGINE_MODE.SOLID:
		if Input.is_action_just_pressed(action) or current_thrust_ratio != 0.:
			return 1.
	elif mode == ENGINE_MODE.LIQUID:
		if Input.is_action_pressed(action):
			return lerpf(current_thrust_ratio, 1., acceleration)
		elif Input.is_action_just_released(action):
			return 0.
	
	return 0.
	
func can_run():
	return (action != "") and current_tank_level > 0 and enabled

func _process(delta):
	var e := can_run()
	
	if e:
		var offset = parent_ship.global_position - self.global_position
		var thrust_vector = (thrust_target.global_position - self.global_position).normalized()
		
		current_thrust_ratio = get_thrust_ratio()
		
		var thrust = current_thrust_ratio * max_thrust
		parent_ship.apply_force(thrust_vector * thrust, offset)
		
		var consumption = current_thrust_ratio * tank_max_consumption
		current_tank_level -= consumption
		
		if current_tank_level <= 0.:
			out_of_fuel.emit()
		
	db_tex.look_at(thrust_target.global_position)
	db_tex.visible = current_thrust_ratio != 0. and e
