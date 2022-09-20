extends TNValue
class_name TN_function

## Class that represents a function in Toy Nano.

## The parameters of the function
var params := []
## The context in which this function was defined.
var parent_context : TNContext

func _init(_parent_context : TNContext, _params, _body):
	params = _params
	_data = _body
	parent_context = _parent_context
	_type = parent_context.constants[&"function"]

## Method to call this function from inside Toy Nano.
func TN_call(receiver, args : Array):
	var context
	
	## Assign the parent_context's constants
	## to the execution context of this function.
	if parent_context:
		context = TNContext.new(parent_context.constants, receiver)
	else:
		context = TNContext.new({}, receiver)
	
	## Assigns the arguments to local variables
	if params.size() != args.size():
		print("(!) Temporary error -- wrong number of arguments!")
		return
	
	for i in params.size():
		context.local_variables[params[i]] = args[i]
	
	print_rich(context)

func _to_string():
	return "fn with params " + str(params) + " and body " + str(_data)
