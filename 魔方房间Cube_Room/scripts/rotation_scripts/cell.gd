class_name Cell
var location:Vector3i = Vector3i(0,0,0)
var item:int = 0
var orientation:int = 0

static func construct(location:Vector3i, item:int, orientation:int)->Cell:
	var cell = Cell.new()
	cell.location = location
	cell.item = item
	cell.orientation = orientation
	return cell
