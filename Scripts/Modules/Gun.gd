class_name LanderGun
extends LanderModule

signal out_of_ammo(gun)

@onready var muzzle := %Muzzle

@export var muzzle_velocity := 10000.
@export var autofire := true
# rounds per second
@export_range(0.1, 1000, 0.1) var rps := 5.
@export_range(0., 1., .01) var max_spread : float = .1
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
	# WHY DO I NEED THIS?????
	bullet_scn = preload("res://Scenes/bullet.tscn")
	
	parent_ship.add_gun(self)
	
	timer = Timer.new()
	timer.one_shot = true
	
	add_child(timer)

func _process(delta):
	var target = get_global_mouse_position()
	look_at(target)
	
	if can_shoot():
		var b : Bullet = bullet_scn.instantiate()
		b.add_collision_exception_with(parent_ship)
		
		var target_dist = global_position.distance_squared_to(target)
		var angle = rotation
		
		var angle_delta = remap(randf(), 0., 1., -1., 1.) * max_spread/2. * PI/3.
		angle += angle_delta
		
		target.x = target_dist * cos(angle)
		target.y = target_dist * sin(angle)
		
		b.shoot(target, muzzle_velocity, muzzle.global_position, get_tree().root, parent_ship.linear_velocity)
		current_ammo_count -= 1
		
		if current_ammo_count <= 0:
			out_of_ammo.emit(self)
		
		timer.start(1. / rps)
		
func can_shoot():
	enabled = enabled and (current_ammo_count > 0)
	
	if not enabled:
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
