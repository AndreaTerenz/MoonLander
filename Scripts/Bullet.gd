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

func shoot(target : Vector2, speed : float, muzzle_pos : Vector2, tree_root: Node, initial_vel : Vector2):
	tree_root.add_child(self)
	global_position = muzzle_pos
	
	if was_shot:
		return
	
	was_shot = true
	var dir = target - self.global_position
	
	look_at(target)
	rotate(PI/2)
	apply_central_force(dir.normalized() * speed)
	
	if initial_vel.length_squared() != 0.:
		linear_velocity += initial_vel
	
	fuze.start()

func _on_body_entered(body):
	if was_shot:
		remove()

func remove():
	queue_free()
