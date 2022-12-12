extends Node

var enabled := true

func ic(data, args : Array = []):
	if data is String and len(args) > 0:
		_print("IC | " + (data % args))
		return args
	
	_print(data)
	return data

func _print(s):
	if enabled:
		print(s)
