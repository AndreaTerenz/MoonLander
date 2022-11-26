extends Node

static func ic(data, args : Array = []):
	if data is String and len(args) > 0:
		print(data % args)
		return args
	
	print(data)
	return data
