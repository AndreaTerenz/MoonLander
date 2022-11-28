extends Node2D

@onready var muzzle := %Muzzle
@onready var timer := %Timer

@export var muzzle_velocity = 10000.0
@export var autofire := true
# rounds per second
@export_range(0.1, 1000, 0.1) var rps := 5.
@export_range(0., 1., .01) var max_spread = .1
@export var bullet_scn = preload("res://Scenes/bullet.tscn")

var parent_ship : Lander = null

func _ready():
	timer.wait_time = (1.0 / rps)
	timer.one_shot = true
	
	var p = get_parent()
	await p.ready
	
	if p is Lander:
		parent_ship = p

func _process(delta):
	var target = get_global_mouse_position()
	look_at(target)
	
	if can_shoot():
		var b : Bullet = bullet_scn.instantiate()
		b.add_collision_exception_with(parent_ship)
		
		var target_dist = global_position.distance_squared_to(target)
		var angle = rotation
		
		angle += remap(randf(), 0., 1., -1., 1.) * max_spread/2. * PI/3.
		
		target.x = target_dist * cos(angle)
		target.y = target_dist * sin(angle)
		
		b.shoot(target, muzzle_velocity, muzzle.global_position, get_tree().root)
		timer.start()
		
func can_shoot():
	if autofire:
		return (Input.is_action_pressed("shoot") and timer.is_stopped())
	else:
		return (Input.is_action_just_pressed("shoot"))
