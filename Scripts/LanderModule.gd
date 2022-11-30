class_name LanderModule
extends Node2D

@export var enabled := true

var parent_ship : Lander = null

func setup(p: Lander):
	parent_ship = p
