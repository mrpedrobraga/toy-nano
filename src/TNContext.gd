extends RefCounted
class_name TNContext

## A class that holds an execution context.
##
## This class contains everything needed to run
## a block of instructions: a reference to the global constants,
## its local variables and the current lexical owner.

## The local variables of this execution context.
var local_variables : Dictionary
## The lexical owner within this execution context.
var current_lexical_owner
## The global constants that this execution context has access to.
var constants : Dictionary

func _init(constants_reference : Dictionary, _current_lexical_owner):
	local_variables = {}
	current_lexical_owner = _current_lexical_owner
	constants = constants_reference

func _to_string():
	var t := ""
	
	## GLOBAL CONSTANTS
	
	t += "-- GLOBALS --\n\n"
	
	t += "[table=2]"
	
	for key in constants.keys():
		t += "[cell]%s  [/cell][cell]: %s[/cell]" % [key, constants[key]]
	
	t += "[/table]\n\n"
	
	## LOCAL VARIABLES
	
	t += "-- LOCALS --\n\n"
	
	t += "[table=2]"
	
	for key in local_variables.keys():
		t += "[cell]%s  [/cell][cell]: %s[/cell]" % [key, local_variables[key]]
	
	t += "[/table]\n\n"
	
	return t
