extends RefCounted
class_name TNRuntime

##Runtime for Toy Nano
##
##A runtime that executes parsed Nano code.

## A type, which has a name
class TN_Type:
	var _name : StringName
	
	func _init(__name : StringName = &"UNDEFINED"):
		_name = __name
	
	func _to_string():
		return str(_name)

## A value, which can have a type and a size
## This is an abstract class.
class TN_Value:
	## The type of the data
	var _type : TN_Type
	## The size of the data in bytes
	var _size : int = 4
	
	## The data this value holds, as abstracted
	## thru two virtual functions.
	##
	## In the serious implementation,
	## this can be a buffer -- but here
	## letting it be virtual allows each implementation
	## of TN_Value to have its own typed variable
	## for its data.
	func _set_data(__data):
		pass
	
	func _get_data():
		pass
	
	## To-String function, good for debugging.
	func _to_string():
		return "<val %s = %s>" % [_type, str(_get_data())]

## A nano boolean value
class TN_bool extends TN_Value:
	## The int this value holds
	var _data : bool = false
	
	func _init(__data:bool=false):
		_data = __data
		_type = TN_Type.new(&"BUILTIN_BOOLEAN")
	
	func _set_data(__data): if __data is bool : _data = __data
	func _get_data(): return _data

## A nano integer value
class TN_int extends TN_Value:
	## The int this value holds
	var _data : int = 0
	
	func _init(__data:int=0):
		_data = __data
		_type = TN_Type.new(&"BUILTIN_INTEGER")
	
	func _set_data(__data): if __data is int : _data = __data
	func _get_data(): return _data
