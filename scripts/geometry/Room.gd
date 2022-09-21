extends CSGPolygon

# north = 
# south = 
# east = 
# west = [0].x, [6].x, [4].x, [5].x
# bump = -[3].y, -[4].y

#		4-------3
#		|		|
#	6---5-------2
#	|			|
#	0-----------1

var has_bump: bool = true

enum RoomType {
	KITCHEN,
	BRAINWASHING,
	BEDROOM,
	BATHROOM,
	GARDEN
}

func constrain_bump():
	if !has_bump:
		polygon[3] = polygon[2]
		polygon[4] = polygon[5]

func _ready():
	set_bump(false)
	expand_north(5)
	expand_bump(5)
		
func expand_north(amount: int = 0):
	for index in [2, 3, 4, 5, 6]:
		polygon[index].y -= amount
	constrain_bump()
	
func expand_south():
	pass
	
func expand_east():
	pass
	
func expand_west(amount: int = 0):
	polygon[0].x -= amount
	polygon[6].x -= amount
	
func expand_bump(amount: int = 0):
	polygon[3].y -= amount
	polygon[4].y -= amount
	#constrain_bump()
	
func set_bump_width(sub: int = 0):
	polygon[4].x = polygon[0].x + sub
	polygon[5].x = polygon[0].x + sub

func set_bump(active: bool = true):
	has_bump = active
	if active:
		polygon[3].y -= 1
		polygon[4].y -= 1
