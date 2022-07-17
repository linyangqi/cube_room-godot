extends Node
# 其实原本也可以直接集中在level的脚本中吧……不过分散开来逻辑应该更清楚点
#或者特色功能放在子节点？
# 而且level还可以另外附加个性化的关卡效果（预留一下）
# 主：目前旋转方式可能和网格还没有完全对应……（需要调整……四舍五入方式？……至少对准一个格子吧）

enum {X = 0, Y = 1, Z = 2}
enum Axis {X = 0, Y = 1, Z = 2}
const cell_offset = Vector3(0.5,0.5,0.5)

#方盒是绝对坐标，不是相对于center的offset
#选取范围似乎会向正轴偏一些？
func get_rotation_box(center:Vector3,axis:Axis,hight:int,expand:int)->AABB:
	var start:Vector3
	var size:Vector3
	match axis :
		X:
			size = Vector3(hight,2*expand+1,2*expand+1)
			start = center+Vector3(0,-expand,-expand)
		Y:
			size = Vector3(2*expand+1,hight,2*expand+1)
			start = center+Vector3(-expand,0,-expand)
		Z:
			size = Vector3(2*expand+1,2*expand+1,hight)
			start = center+Vector3(-expand,-expand,0)
			
	return AABB(start, size)


func modi(value:int,mod:int)->int:
	value = value % mod
	if value<0:
		value += mod
	return value

func rotated_offest(axis:Axis, offset:Vector3, times:int = 1)->Vector3:
	var new_offset:Vector3 = offset
	for i in (modi(times,4)): #
		match axis :
			X: # Y->Z （X轴不变）
				new_offset.z = offset.y
				new_offset.y = -offset.z
			Y: # Z->X
				new_offset.x = offset.z
				new_offset.z = -offset.x
			Z: # X->Y
				new_offset.y = offset.x
				new_offset.x = -offset.y
		offset = new_offset
	return offset


##############
#目前旋转方式可能和网格还没有完全对应……
# 不加cell_offet的话，表现在grid不带center状态下就正常，但是grid会……
#好吧，为了省事，还是用调整grid的方法吧……大不了设计时装上，完了后取消掉
func rotate_entity(center:Vector3,axis:Axis, entity:Node3D, times:int = 1):
	var offset = entity.position - center
	var new_offset = rotated_offest(axis, offset, times)
	entity.position = center + new_offset
	


func rotate_entities(center:Vector3,axis:Axis,hight:int,expand:int, times:int = 1):
	#传入的center是与Entities的相对坐标（绝对坐标减法），所以这里下面的实体使用本地变换transform应该就可以
	#对于一个旋转层而言，控制的旋转层一般是不中途改变的……
	#但是如果搞运动中的节点……就需要在旋转时再获取一下大小吧
	var rotation_box:AABB = get_rotation_box(center,axis,hight,expand)
	for entity in get_children():
		if rotation_box.has_point(entity.global_transform.origin):
			#这里的“旋转”实际上是改变坐标，而不是物体自身旋转了……应该没有自带函数吧
			rotate_entity(center, axis, entity, times)
			pass
