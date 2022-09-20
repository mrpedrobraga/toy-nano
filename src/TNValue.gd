class_name TNValue
## A value in Toy Nano
##
## This class is a value -- it holds the data of the value,
## its type and its size.

## The type of the data
var _type

## The data this value holds
var _data

## The size of the data in bytes
var _size : int = 4

## To-String function, good for debugging.
func _to_string():
	return str(_data)
