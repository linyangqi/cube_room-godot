extends Node3D

# 模仿b站搬运 BV15f4y17ER 的做法
# 然而GD4.0好像没有ClippedCamera了
var camrot_h = 0
var camrot_v = 0
var cam_v_max = PI/2
var cam_v_min = -PI/2
var h_sensitivity = 0.005
var v_sensitivity = 0.005
var h_acceleration = 20
var v_acceleration = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass # Replace with function body.


func _input(event):
	if event is InputEventMouseMotion:
		camrot_h += -event.relative.x  * h_sensitivity
		camrot_v += -event.relative.y  * v_sensitivity
		camrot_v = clamp(camrot_v, cam_v_min, cam_v_max)


func _physics_process(delta):

#	$h.rotation.y = lerp($h.rotation.y, camrot_h, delta * h_acceleration)
#	$h/v.rotation.x = lerp($h/v.rotation.x, camrot_v, delta * v_acceleration)
	$h.rotation.y = camrot_h
	$h/v.rotation.x = camrot_v
	
