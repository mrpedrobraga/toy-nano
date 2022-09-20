extends RefCounted
class_name TNRuntime

##Runtime for Toy Nano
##
##A runtime that executes parsed Nano code.

var context : TNContext
var constants := {}

# A handy reference to the 'type' [TN_type].
var _tn_type : TN_type

# Helper macro that creates a new instance of TN_type quickly,
# assiging _tn_type as the type of the newly created value.
func _new_type():
	var t = TN_type.new()
	t._type = _tn_type
	return t

func _init():
	# initialize the context.
	# it has a reference to the global constants
	context = TNContext.new(constants, null)
	
	# Create a new [TN_type] instance that will be the
	# type of nano values that store a type.
	_tn_type = TN_type.new()
	_tn_type._type = _tn_type
	
	## Creating constants for the built-in types.
	## Notice all these constants are of type 'type'.
	constants[&"type"] 		= _tn_type
	constants[&"bool"] 		= _new_type()
	constants[&"int"] 		= _new_type()
	constants[&"float"] 	= _new_type()
	constants[&"string"] 	= _new_type()
	constants[&"function"] 	= _new_type()
	constants[&"NullType"] 	= _new_type()
	
	## Declare constants of type 'boolean' with some values.
	constants[&"true"] 	= constants[&"bool"].new_instance(true)
	constants[&"yes"] 	= constants[&"bool"].new_instance(true)
	constants[&"on"] 	= constants[&"bool"].new_instance(true)
	constants[&"false"] = constants[&"bool"].new_instance(false)
	constants[&"no"] 	= constants[&"bool"].new_instance(false)
	constants[&"off"] 	= constants[&"bool"].new_instance(false)
	
	# Declare TAU, a float constant, for fun
	constants[&"TAU"]	= constants[&"float"].new_instance(TAU)
	
	# Declare print, a function constant.
	constants[&"print"]	= TN_function.new(context, [&"what"], [])
	
	# Test calling a defined function!!!
	constants[&"print"].TN_call(null, ["hello world"])
