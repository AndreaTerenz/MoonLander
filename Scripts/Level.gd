class_name Level
extends Node2D

enum STATE {
	TO_NEXT,
	MIDDLE,
	TO_PREV
}

@export_file("*.tscn") var next_level_scn = ""
@export_file("*.tscn") var prev_level_scn = ""

@export var next_trigger : Area2D = null
@export var prev_trigger : Area2D = null

var lander : Lander = null
var state = STATE.MIDDLE:
	set(new_state):
		set_state(new_state)
		
var next_level : Level = null
var prev_level : Level = null

func _ready():
	if not Globals.lander:
		await Globals.lander_set
		
	lander = Globals.lander

	setup_trigger(next_trigger, STATE.TO_NEXT)
	setup_trigger(prev_trigger, STATE.TO_PREV)
		
func setup_trigger(trig: Area2D, enter_state):
	if trig:
		trig.body_entered.connect(
			func(body):
				if body == lander:
					state = enter_state
		)
		trig.body_exited.connect(
			func(body):
				if body == lander:
					state = STATE.MIDDLE
		)

func set_state(new_state):
	if next_level_scn == prev_level_scn or (next_level_scn == "" and prev_level_scn == ""):
		return
	
	if new_state == STATE.MIDDLE:
		if state == STATE.TO_NEXT:
			prev_level = load(prev_level_scn).instantiate()
			# pop next level from tree
		if state == STATE.TO_PREV:
			# pop prev level from tree
			next_level = load(next_level_scn).instantiate()
	
	if new_state == STATE.TO_NEXT:
		if state == STATE.MIDDLE:
			get_tree().root.add_child(next_level)
			prev_level.queue_free()
	
	if new_state == STATE.TO_PREV:
		if state == STATE.MIDDLE:
			get_tree().root.add_child(prev_level)
			next_level.queue_free()
