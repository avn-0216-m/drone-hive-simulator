extends Node

class_name TestResult

var step: Step
var next: Step
var collision: Vector3 # the point before a collision was detected.
var successful: bool = true # if there was a collision.

func _init(first := Step.new(), second := Step.new()):
	
	self.step = first
	self.next = first.next
