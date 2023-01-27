class_name Bullet
extends RigidBody2D

@export_range(0.1, 1000, 0.1) var fuze_length = 2.

var was_shot := false
var fuze := Timer.new()

func _ready():
	contact_monitor = true
	max_contacts_reported = 1
	gravity_scale = 0
	
	add_child(fuze)
	fuze.wait_time = fuze_length
	fuze.one_shot = true
	fuze.timeout.connect(
	func() : 
		remove()
	)

func shoot(target : Vector2, speed : float, muzzle_pos : Vector2, spread_factor: float, vel_rand_factor: float, tree_root: Node):
	tree_root.add_child(self)
	global_position = muzzle_pos
	
	if was_shot:
		return
	
	was_shot = true
	
	var dir = target - self.global_position
	var angle_delta = remap(randf(), 0., 1., -1., 1.) * spread_factor / 2. * PI/6.
	
	dir = dir.normalized()
	dir = dir.rotated(angle_delta)
	
	look_at(to_global(dir))
	rotate(PI/2)
	
	var speed_rand_fact = remap(randf(), 0., 1., 1. - vel_rand_factor/2., 1. + vel_rand_factor/2.)
	apply_central_force(dir * speed * speed_rand_fact)
	
	fuze.start()

func _on_body_entered(body):
	if was_shot:
		remove()

func remove():
	queue_free()
