extends Node3D

# 可以把Grid和 Entities带的代码合到这里，方便统一操作
# 不过旋转层仍然需要通过脚本来提供额外参数，因此旋转层所带脚本需要保留

@onready var rotatoins = $Rotations
@onready var gridmap:GridMap = $GridMap
@onready var entities = $Entities
@onready var player = entities.get_node("Player")


enum Axis{X=0, Y=1, Z=2}
enum {X=0, Y=1, Z=2} #如果前面加了个名字那就是一个“类型”了，不加名字才是纯粹列举

	
func get_rotation_box(center:Vector3i,axis:Axis,hight:int,expand:int)->AABB:
	var start:Vector3i
	var size:Vector3i
	match axis :
		X:
			size = Vector3i(hight,2*expand+1,2*expand+1)
			start = center+Vector3i(0,-expand,-expand)
		Y:
			size = Vector3i(2*expand+1,hight,2*expand+1)
			start = center+Vector3i(-expand,0,-expand)
		Z:
			size = Vector3i(2*expand+1,2*expand+1,hight)
			start = center+Vector3i(-expand,-expand,0)
			
	return AABB(start, size)

#ps：现在的旋转可能还是有点卡？（毕竟是逐个方块操作）
#func rotate_level_old(center:Vector3i, axis:Axis, hight:int, expand:int, times:int = 1):
	#var points = points_in_aabb(get_rotation_quarter(center,axis,hight,expand))
	#for point in points:
		#rotate_4cells(center,axis,point-center,times)

#新版本，就从这里改逻辑吧
func rotate_level(center:Vector3i, axis:Axis, hight:int, expand:int, times:int = 1):
	#var candidate_points:Array[Vector3i] = gridmap.get_used_cells() # 忽略空点
	var area:AABB = get_rotation_box(center,axis,hight,expand) # 有效区域
	
	# 选取有效点
	var valid_points:Array[Vector3i] = []
	for point in gridmap.get_used_cells():# 忽略空点
		if area.has_point(point):
			valid_points.append(point)
	# 记录单元格数据
	var cell_accounts:Array[Cell]=[]
	for point in valid_points:
		cell_accounts.append(Cell.gridmap_construct(point,gridmap))
		gridmap.set_cell_item(point,GridMap.INVALID_CELL_ITEM) # 清空以示“拿取”
	for cell in cell_accounts: # 每个cell作旋转处理
		cell.rotate(center, axis, times)
		cell.apply(gridmap)
		
	
	
	
	
	
	
