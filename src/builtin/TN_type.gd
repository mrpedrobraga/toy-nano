extends TNValue
class_name TN_type

## A class that holds an instance of a type.

## Creates a new value and returns it...[br][br]
## This new value will be of type <type>
## where <type> is the instance of [TN_type]
## this method was called from.
func new_instance(__data=null) -> TNValue:
	var i = TNValue.new()
	i._data = __data
	i._type = self
	return i

func _to_string():
	return "TYPE"
