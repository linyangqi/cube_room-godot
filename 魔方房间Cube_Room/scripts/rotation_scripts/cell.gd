class_name Cell
#操作用的cell
var location:Vector3i 
var item:int 
var basis:Basis 

enum Axis{X=0, Y=1, Z=2}
enum {X=0, Y=1, Z=2} #如果前面加了个名字那就是一个“类型”了，不加名字才是纯粹列举
const AXIS_DIRECTION = [Vector3(1,0,0),Vector3(1,0,0),Vector3(1,0,0)]

# 从gridmap获取cell的数据
static func gridmap_construct(location:Vector3i,gridmap:GridMap)->Cell:
	var cell = Cell.new()
	cell.location = location
	cell.item = gridmap.get_cell_item(location)
	cell.basis = gridmap.get_cell_item_basis(location)
	return cell

# 旋转改变位置的核心代码
static func rotated_offest(axis:int, offset:Vector3i, times:int = 1)->Vector3i:
	var new_offset:Vector3i = offset
	for i in (posmod(times,4)): #
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


func rotate(center:Vector3i, axis:int, times:int = 1):
	var new_offset:Vector3i = rotated_offest(axis,location-center, times)
	location = center + new_offset
	basis = basis.rotated(AXIS_DIRECTION[axis], times * PI/2)
	
func apply(gridmap:GridMap):
	gridmap.set_cell_item(location, item, gridmap.get_orthogonal_index_from_basis(basis))
	
