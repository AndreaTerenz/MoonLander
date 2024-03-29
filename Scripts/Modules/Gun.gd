class_name LanderGun
extends LanderModule

signal out_of_ammo(gun)

@onready var muzzle := %Muzzle

@export var muzzle_velocity := 10000.
@export var autofire := true
# rounds per second
@export_range(0.1, 1000, 0.1) var rps := 5.
@export_range(0., 1., .01) var max_spread : float = .1
@export_range(.01, 1., .01) var bullet_vel_randomness : float = .1
@export var max_ammo := 1000.
@export var bullet_scn = preload("res://Scenes/bullet.tscn")

var timer : Timer = null
var current_ammo_count := max_ammo
var ammo_ratio :
	get:
		return current_ammo_count/max_ammo
var ammo_missing :
	get:
		return max_ammo-current_ammo_count

func setup(p: Lander):
	super.setup(p)
	
	parent_ship.add_gun(self)
	
	timer = Timer.new()
	timer.one_shot = true
	
	add_child(timer)

func _process(delta):
	var mouse_pos = get_global_mouse_position()
	var target = Utils.get_furthest(global_position, mouse_pos, muzzle.global_position)
	
	look_at(target)
	
	if can_shoot() and target == mouse_pos:
		var b : Bullet = bullet_scn.instantiate()
		add_child(b)
		
		b.add_collision_exception_with(parent_ship)
		b.shoot(target, muzzle_velocity, muzzle.global_position, max_spread, bullet_vel_randomness)
		
		current_ammo_count -= 1
		
		if current_ammo_count <= 0:
			out_of_ammo.emit(self)
		
		timer.start(1. / rps)
		
func can_shoot():
	if not enabled or (current_ammo_count <= 0):
		return false
		
	if autofire:
		return (Input.is_action_pressed("shoot") and timer.is_stopped())
	else:
		return (Input.is_action_just_pressed("shoot"))
	
func get_resource_level():
	return current_ammo_count
	
func get_resource_max():
	return max_ammo
	
func get_resource_delta():
	return max_ammo-current_ammo_count
	
func add_resource(amount):
	current_ammo_count += amount
