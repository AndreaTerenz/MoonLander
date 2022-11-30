class_name Lander
extends RigidBody2D

@onready var crosshair : Sprite2D = %Crosshair

var engines : Array[LanderEngine] = []
var guns : Array[LanderGun] = []

func _ready():
	Globals.set_lander(self)
	
func add_engine(e: LanderEngine):
	if not e in engines:
		engines.append(e)
	
func add_gun(g: LanderGun):
	if not g in guns:
		guns.append(g)
