extends Node

var enabled := true

func ic(data, args : Array = []):
	if enabled:
		if data is String and len(args) > 0:
			print("IC | ",data % args)
			return args
		
		print(data)
		return data

