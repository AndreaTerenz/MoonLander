extends Node

signal lander_set(l)

var lander : Lander = null

func set_lander(l: Lander):
	if not lander:
		lander = l
		lander_set.emit(lander)
