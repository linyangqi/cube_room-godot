extends Node3D

# 可以把Grid和 Entities带的代码合到这里，方便统一操作
# 不过旋转层仍然需要通过脚本来提供额外参数，因此旋转层所带脚本需要保留

@onready var rotatoins = $Rotations
@onready var gridmap = $GridMap
@onready var entities = $Entities
@onready var player = entities.get_node("Player")


enum Axis{X=0, Y=1, Z=2}
enum {X=0, Y=1, Z=2} #如果前面加了个名字那就是一个“类型”了，不加名字才是纯粹列举

func _ready():
	gridmap.cell_center_x = false
	gridmap.cell_center_y = false
	gridmap.cell_center_z = false


#############################
#单元格部分
func set_cell(cell:Cell):
	gridmap.set_cell_item(cell.location, cell.item, cell.orientation)
	
func set_cells(cells:Array[Cell]):
	for cell in cells:
		set_cell(cell)

func get_cell(location:Vector3i)->Cell:
	var item = gridmap.get_cell_item(location)
	var orientation = gridmap.get_cell_item_orientation(location)
	#不会构造函数……似乎只用这样一个个参数地改吗……（有点麻烦）……或者“非本名”的构造函数这样？
	return Cell.construct(location,item,orientation)


########################################


###################
#旋转一个
# TODO: 方块自身朝向的变换!!!!!!!!!!!!!!!!!!!!

#保证非负的取余方法（godot自带的取余会保留符号……）
func modi(value:int,mod:int)->int:
	value = value % mod
	if value<0:
		value += mod
	return value

#这里的旋转times，除了rotated_offset确实使用了for，其他都是调用此函数来做到一次变换/一步到位
func rotated_offest(axis:Axis, offset:Vector3i, times:int = 1)->Vector3i:
	var new_offset:Vector3i = offset
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


func rotate_cell(center:Vector3i, axis:Axis, offset:Vector3i, times:int = 1):
	set_cell(rotated_cell(center, axis, offset, times))

func rotated_cell(center:Vector3i, axis:Axis, offset:Vector3i, times:int = 1)->Cell:
	var cell:Cell=get_cell(center+offset)
	var new_offset:Vector3i = rotated_offest(axis,offset, times)
	cell.location = center + new_offset
	return cell

#数组方案，但是一次会传入一个数组……会影响性能吧？
func rotate_cells(center:Vector3i, axis:Axis, cells:Array[Cell],times:int = 1):
	set_cells(rotated_cells(center, axis, cells, times))
	
func rotated_cells(center:Vector3i, axis:Axis, cells:Array[Cell],times:int = 1)->Array[Cell]:
	for i in cells.size():
		cells[i] = rotated_cell(center, axis, cells[i].offset, times)
	return cells


#######################
#大量cell下的处理

#旋转4个（同时）
func rotate_4cells(center:Vector3i, axis:Axis, offset:Vector3i, times:int = 1):
	var cells:Array[Cell] = []
	for i in 4:
		cells.append(rotated_cell(center, axis, offset, times)) # 缓存旋转结果
		offset = rotated_offest(axis,offset) # 定位下一块
	set_cells(cells) # 缓存区结果应用

#遍历所有，但是不建立数组——仅仅遍历式地使用rotate_4cells（但是逻辑上就困难些……有必要吗）
#至少要有一个可以遍历“位置”的方法吧？（一片区域的）
func points_in_area(start:Vector3i, end:Vector3i)->Array[Vector3i]:
	var points:Array[Vector3i] = []
	for x in range(start.x, end.x): # range() 要求的参数是int
		for y in range(start.y, end.y):
			for z in range(start.z, end.z):
				points.append(Vector3i(x,y,z))
	return points

func points_in_aabb(aabb:AABB)->Array[Vector3i]:
	var points:Array[Vector3i] = []
	for x in range(aabb.position.x, aabb.end.x): # range() 要求的参数是int,float会强制转换
		for y in range(aabb.position.y, aabb.end.y):
			for z in range(aabb.position.z, aabb.end.z):
				points.append(Vector3i(x,y,z))
	return points

#方盒是grid中的绝对坐标，不是相对于center的offset
func get_rotation_quarter(center:Vector3i,axis:Axis,hight:int,expand:int):
	var start:Vector3i
	var size:Vector3i
	match axis :
		X:
			size = Vector3i(hight,expand+1,expand)
			start = center+Vector3i(0,-expand,-expand)
		Y:
			size = Vector3i(expand+1,hight,expand)
			start = center+Vector3i(-expand,0,-expand)
		Z:
			size = Vector3i(expand+1,expand,hight)
			start = center+Vector3i(-expand,-expand,0)
			
	return AABB(start, size)

#ps：现在的旋转可能还是有点卡？（毕竟是逐个方块操作）
func rotate_level(center:Vector3i, axis:Axis, hight:int, expand:int, times:int = 1):
	var points = points_in_aabb(get_rotation_quarter(center,axis,hight,expand))
	for point in points:
		rotate_4cells(center,axis,point-center,times)
