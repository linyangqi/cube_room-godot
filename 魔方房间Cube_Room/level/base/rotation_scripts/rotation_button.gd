extends Button

@export var rotation_node:Node

func _pressed():
	rotation_node.rotate_level()
