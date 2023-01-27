class_name Lander
extends RigidBody2D

enum MODE {
	NORMAL,
	DOCKING,
	DOCKED,
}

signal engine_added(eng)
signal gun_added(gun)

signal entered_harbor(harb)
signal docking_start(harb)
signal docked(harb)
signal undocked(harb)
signal left_harbor(harb)

signal mode_changed(m)

@export_range(10., 900, .01)
var docking_speed := 90.

@onready var crosshair : Sprite2D = %Crosshair

var engines : Array[LanderEngine] = []
var guns : Array[LanderGun] = []
var mode := MODE.NORMAL :
	get:
		return mode
	set(newMode):
		_on_mode_changed(newMode)
		
		mode = newMode
		mode_changed.emit(mode)
var current_harbor : Harbor = null
var harbor_target : Node2D = null

func _ready():
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	
	for kid in get_children():
		if kid is LanderModule:
			kid.setup(self)
			
			if kid is LanderEngine:
				add_engine(kid)
			elif kid is LanderGun:
				add_gun(kid)
	
	Globals.set_lander(self)
	
func _physics_process(delta):
	if mode != MODE.DOCKING:
		return
		
	var ht_pos = harbor_target.global_position
	
	rotation = lerp_angle(rotation, 0., .1)
	
	var dir := (ht_pos - global_position).normalized()
	var coll = move_and_collide(dir * docking_speed * delta)
	
	if (coll != null) or (ht_pos.distance_to(global_position) < .001):
		docked.emit(current_harbor)
		mode = MODE.DOCKED

func _input(_event):
	if Input.is_action_just_pressed("dock") and current_harbor != null:
		match mode:
			MODE.NORMAL:
				start_docking()
			MODE.DOCKING:
				pass
			MODE.DOCKED:
				mode = MODE.NORMAL
				
				undocked.emit(current_harbor)

func add_engine(e: LanderEngine):
	if not e in engines:
		engines.append(e)
		e.out_of_fuel.connect(self._on_outta_fuel)
		engine_added.emit(e)
	
func add_gun(g: LanderGun):
	if not g in guns:
		guns.append(g)
		g.out_of_ammo.connect(self._on_outta_ammo)
		gun_added.emit(g)

func _on_outta_fuel(engine: LanderEngine):
	print("Engine '%s' is out of fuel!" % engine.name)

func _on_outta_ammo(gun: LanderGun):
	pass
	
func collect_fuel(amount: float):
	collect_resource(amount, engines)

func collect_ammo(amount: float):
	collect_resource(amount, guns)

func collect_resource(initial_amount : float, modules: Array):
	var deltas : Array[float] = []
	var count := len(modules)
	deltas.resize(count)
		
	var delta_tot : float = 0.
	var amount_left : float = initial_amount
	var rel_deltas : Array[float] = []
	var allotted : Array[float] = []
	
	rel_deltas.resize(count)
	allotted.resize(count)
		
	for i in range(count):
		deltas[i] = modules[i].get_resource_delta()
		delta_tot += deltas[i]
		allotted[i] = 0.
		
	while (amount_left > 0) and (delta_tot > 0):
		var all_tot = 0.
		
		for i in range(count):
			# normalization
			rel_deltas[i] = deltas[i] / delta_tot
			var new_allotted = float(min(rel_deltas[i] * amount_left, deltas[i]))
			allotted[i] += (new_allotted)
			deltas[i] -= new_allotted
			all_tot += (new_allotted)
			
		amount_left -= all_tot
		delta_tot -= all_tot
			
	for i in range(count):
		modules[i].add_resource(allotted[i])
		
func _on_mode_changed(newMode: MODE):
	if (newMode == MODE.DOCKING):
		linear_velocity *= 0.
	
	freeze = (newMode != MODE.NORMAL)
	
	for e in engines:
		e.enabled = not (newMode != MODE.NORMAL)
		
func enter_harbor(h: Harbor):
	entered_harbor.emit(h)
	current_harbor = h
		
func leave_harbor(h: Harbor):
	if h == current_harbor:
		left_harbor.emit(h)
		current_harbor = null

func start_docking():
	mode = MODE.DOCKING
	harbor_target = current_harbor.target
	docking_start.emit(current_harbor)
