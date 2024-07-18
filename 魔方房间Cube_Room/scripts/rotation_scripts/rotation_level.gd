extends Node3D
#ps： 这个脚本其实也可以挂在Entities的子节点中，作为“移动的旋转轴”

#控制范围（广度、厚度，以及方向）
enum {X = 0, Y = 1, Z = 2}
enum Axis {X = 0, Y = 1, Z = 2}
@export var axis:Axis
@export var hight:int = 1 # postive direction
@export var expand:int = 0

# 子节点加载出来时父节点还没出来，所以需要onready来延迟一下
@onready var level_root = get_owner()
@onready var gridmap = level_root.get_node("GridMap")
@onready var entities = level_root.get_node("Entities")
@onready var player = entities.get_node("Player")
#旋转方块是gird的事，但是旋转实体位置之类就可以单独分到这里了——不过还是放到另一个“Entities”节点里了
#而且除了玩家以外，还有其他实体也应该能旋转的
#func get_rotation_box(center:Vector3i,axis:Axis,hight:int,expand:int)->AABB:
	#var start:Vector3i
	#var size:Vector3i
	#match axis :
		#X:
			#size = Vector3i(hight,2*expand+1,2*expand+1)
			#start = center+Vector3i(0,-expand,-expand)
		#Y:
			#size = Vector3i(2*expand+1,hight,2*expand+1)
			#start = center+Vector3i(-expand,0,-expand)
		#Z:
			#size = Vector3i(2*expand+1,2*expand+1,hight)
			#start = center+Vector3i(-expand,-expand,0)
			#
	#return AABB(start, size)



func rotate_level():
	#右手螺旋法则式旋转
	level_root.rotate_level(global_transform.origin - gridmap.global_transform.origin,axis,hight,expand)
	# gridmap中的方块操作函数基本上都是相对位置的样子？
	
	#entity旋转
	entities.rotate_entities(global_transform.origin - entities.global_transform.origin,axis,hight,expand)
