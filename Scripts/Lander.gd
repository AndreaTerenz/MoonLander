class_name Lander
extends RigidBody2D

signal engine_added(eng)
signal gun_added(gun)

@onready var crosshair : Sprite2D = %Crosshair

var engines : Array[LanderEngine] = []
var guns : Array[LanderGun] = []

func _ready():
	for kid in get_children():
		if kid is LanderModule:
			kid.setup(self)
			
			if kid is LanderEngine:
				add_engine(kid)
			elif kid is LanderGun:
				add_gun(kid)
	
	Globals.set_lander(self)
	
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
		

