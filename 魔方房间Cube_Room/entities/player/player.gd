extends CharacterBody3D

# 这里是有自带模板的，不过还是仿照教程 BVNy4y1q71z 改一下
# 另外视频教程中键位还没有Physics的键盘代码，大概是新的功能吧
# GD4.0版本这里velocity已经是CharacterBody3D自带的一个属性了23333

const SPEED = 5.0
const SNEAK_SPEED_FACTOR = 0.2
const JUMP_VELOCITY = 4.5

@onready var check_point = transform.origin 

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
#var gravity = 0


func _process(_delta):
	#落下归位
	if transform.origin.y < -100:
		transform.origin = check_point
		velocity = Vector3.ZERO
			

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
#		check_point = transform.origin # 归档重生点……不过可能应该改改

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#后面观察了一下原模板代码，发现只要把方向加上去就能用了（get_vector方式使得获取输入的代码十分简洁了，这个可能是新加的函数？）
	var h_rot = $CameraRoot/h.global_transform.basis.get_euler().y
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).rotated(Vector3.UP, h_rot).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if Input.is_action_pressed("sneak"):
		velocity *= SNEAK_SPEED_FACTOR
		# 然而并没有防坠落的功能

	move_and_slide()
