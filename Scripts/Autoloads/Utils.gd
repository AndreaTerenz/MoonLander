extends Node

var layers = []

func _ready() -> void:
	for i in range(1, 21):
		layers.append(ProjectSettings.get_setting("layer_names/2d_physics/layer_%d" % i))

func get_layer_bit(name: String):
	return layers.find(name)+1
	
func get_layer_bit_in_object(obj, name: String) -> bool:
	return obj.get_collision_layer_value(get_layer_bit(name))
	
func get_mask_bit_in_object(obj, name: String) -> bool:
	return obj.get_collision_mask_value(get_layer_bit(name))
	
func set_layer_bit_in_object(obj, name: String, value := true):
	var bit = get_layer_bit(name)
	obj.set_collision_layer_value(bit, value)
	
func set_mask_bit_in_object(obj, name: String, value := true):
	var bit = get_layer_bit(IC.ic(name))
	obj.set_collision_mask_value(IC.ic(bit), value)
	
func set_layer_bits_in_object(obj, names: Array[String], value := true):
	for n in names:
		set_layer_bit_in_object(obj, n, value)
		
func set_mask_bits_in_object(obj, names: Array[String], value := true):
	for n in names:
		set_mask_bit_in_object(obj, n, value)
	
func toggle_layer_bit_in_object(obj, name: String):
	var current = get_layer_bit_in_object(obj, name)
	set_layer_bit_in_object(obj, name, not current)
	
func toggle_mask_bit_in_object(obj, name: String):
	var current = get_mask_bit_in_object(obj, name)
	set_mask_bit_in_object(obj, name, not current)
	
func toggle_layer_bits_in_object(obj, names: Array[String]):
	for n in names:
		toggle_layer_bit_in_object(obj, n)
		
func toggle_mask_bits_in_object(obj, names: Array[String]):
	for n in names:
		toggle_mask_bit_in_object(obj, n)
