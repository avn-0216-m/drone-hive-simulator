extends Node
class_name Instancable

var path: String = "res://"
var positive_space_int: int
var positive_space: Array
var negative_space_int: int
var negative_space: Array
var testvar: String

static func instance():
	print("Default instance function. Please override.")
