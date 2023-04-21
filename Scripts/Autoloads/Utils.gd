extends Node

var layers = []

func _ready() -> void:
	for i in range(1, 21):
		layers.append(ProjectSettings.get_setting("layer_names/2d_physics/layer_%d" % i))

func get_closest(origin: Vector2, p1: Vector2, p2: Vector2) -> Vector2:
	var d1 := origin.distance_squared_to(p1)
	var d2 := origin.distance_squared_to(p2)
	
	return p1 if d1 <= d2 else p2

func get_furthest(origin: Vector2, p1: Vector2, p2: Vector2) -> Vector2:
	var d1 := origin.distance_squared_to(p1)
	var d2 := origin.distance_squared_to(p2)
	
	return p1 if d1 >= d2 else p2

func get_layer_bit(layer_name: String):
	return layers.find(layer_name)+1
	
func get_layer_bit_in_object(obj, obj_name: String) -> bool:
	return obj.get_collision_layer_value(get_layer_bit(obj_name))
	
func get_mask_bit_in_object(obj, obj_name: String) -> bool:
	return obj.get_collision_mask_value(get_layer_bit(obj_name))
	
func set_layer_bit_in_object(obj, obj_name: String, value := true):
	var bit = get_layer_bit(obj_name)
	obj.set_collision_layer_value(bit, value)
	
func set_mask_bit_in_object(obj, obj_name: String, value := true):
	var bit = get_layer_bit(IC.ic(obj_name))
	obj.set_collision_mask_value(IC.ic(bit), value)
	
func set_layer_bits_in_object(obj, names: Array[String], value := true):
	for n in names:
		set_layer_bit_in_object(obj, n, value)
		
func set_mask_bits_in_object(obj, names: Array[String], value := true):
	for n in names:
		set_mask_bit_in_object(obj, n, value)
	
func toggle_layer_bit_in_object(obj, obj_name: String):
	var current = get_layer_bit_in_object(obj, obj_name)
	set_layer_bit_in_object(obj, obj_name, not current)
	
func toggle_mask_bit_in_object(obj, obj_name: String):
	var current = get_mask_bit_in_object(obj, obj_name)
	set_mask_bit_in_object(obj, obj_name, not current)
	
func toggle_layer_bits_in_object(obj, names: Array[String]):
	for n in names:
		toggle_layer_bit_in_object(obj, n)
		
func toggle_mask_bits_in_object(obj, names: Array[String]):
	for n in names:
		toggle_mask_bit_in_object(obj, n)
