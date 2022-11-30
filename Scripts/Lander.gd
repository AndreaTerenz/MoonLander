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
