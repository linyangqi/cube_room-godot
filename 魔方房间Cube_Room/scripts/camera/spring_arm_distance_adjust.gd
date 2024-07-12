extends SpringArm3D

const MIN_DISTANCE = 0
const MAX_DISTANCE = 20

var distance:float = spring_length
var adjustment:int = 0
var adjust_speed:float = 0.2
var acceleration:float = 3

func _input(event):
	adjustment = 0
	
	if Input.is_action_pressed("camera_in"):
			adjustment -= 1
	if Input.is_action_pressed("camera_out"):
			adjustment += 1
	distance +=  adjustment * adjust_speed * ( 1 + distance / 5 )
	distance = clamp(distance, MIN_DISTANCE, MAX_DISTANCE)

func _physics_process(delta):
	spring_length = lerp(spring_length, distance, delta * acceleration)
#	spring_length = distance
	
