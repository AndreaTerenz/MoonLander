class_name LanderModule
extends Node2D

@export var enabled := true

var parent_ship : Lander = null

func setup(p: Lander):
	parent_ship = p
	
func get_resource_max():
	return -1
	
func get_resource_delta():
	return 0
	
func get_resource_level():
	return 0

func add_resource(amount):
	pass
