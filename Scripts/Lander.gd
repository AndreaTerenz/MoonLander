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
	var delta_tot := INF
	var fuel_left : float = amount
	var deltas : Array[float] = []
	var rel_deltas : Array[float] = []
	var allotted : Array[float] = []
	var engine_count := len(engines)
	
	deltas.resize(engine_count)
	rel_deltas.resize(engine_count)
	allotted.resize(engine_count)
	
	while (fuel_left > 0) and (delta_tot > 0):
		delta_tot = 0
		
		for i in range(engine_count):
			deltas[i] = engines[i].tank_level_missing
			delta_tot += deltas[i]
		print(delta_tot)
			
		for i in range(engine_count):
			# normalization
			rel_deltas[i] = deltas[i] / delta_tot
			allotted[i] = min(rel_deltas[i] * fuel_left, deltas[i])
			engines[i].tank_level += allotted[i]
			print(engines[i].name, " ", rel_deltas[i], " ", allotted[i])
		
		fuel_left = 0
		for i in range(engine_count):
			fuel_left += float(max(allotted[i] - deltas[i], 0.))
