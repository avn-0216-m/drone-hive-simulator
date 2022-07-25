from enum import IntFlag

# Python script to precompute the required tile and orientation of a given
# int value, representing present adjacent tiles.

class Tiles(IntFlag):
    NORTHWEST = 1
    NORTH = 2
    NORTHEAST = 4

    WEST = 8
    EAST = 16

    SOUTHWEST = 32
    SOUTH = 64
    SOUTHEAST = 128

patterns = {
    "[8, 0]": [Tiles.NORTH, Tiles.SOUTH, Tiles.EAST, Tiles.WEST],

    "[6, 0]": [Tiles.NORTH, Tiles.EAST, Tiles.WEST], # North curve
    "[6, 10]": [Tiles.SOUTH, Tiles.EAST, Tiles.WEST], # South curve
    "[6, 22]": [Tiles.EAST, Tiles.NORTH, Tiles.SOUTH], # East curve
    "[6, 16]": [Tiles.SOUTH, Tiles.NORTH, Tiles.WEST], # West curve

    "[7, 22]": [Tiles.NORTH, Tiles.SOUTH], # Horizontal double
    "[7, 0]": [Tiles.EAST, Tiles.WEST], # Vertical double

    "[5, 22]": [Tiles.NORTH, Tiles.EAST], # NE Corner
    "[5, 0]": [Tiles.NORTH, Tiles.WEST], # NW Corner
    "[5, 10]": [Tiles.SOUTH, Tiles.EAST], # SE Corner
    "[5, 16]": [Tiles.SOUTH, Tiles.WEST], # SW Corner

    "[1, 16]": [Tiles.NORTH], # North wall
    "[1, 22]": [Tiles.SOUTH], # South wall
    "[1, 0]": [Tiles.EAST], # East wall
    "[1, 10]": [Tiles.WEST], # West wall

    "[4, 0]": [Tiles.NORTHEAST], # NE Post
    "[4, 16]": [Tiles.NORTHWEST], # NW Post
    "[4, 22]": [Tiles.SOUTHEAST], # SE Post
    "[4, 10]": [Tiles.SOUTHWEST], # SW Post
    }

def get_nearby_tiles_from_int(num: int):

    tiles = []

    if num & Tiles.NORTHWEST:
        tiles.append(Tiles.NORTHWEST)
    if num & Tiles.NORTH:
        tiles.append(Tiles.NORTH)
    if num & Tiles.NORTHEAST:
        tiles.append(Tiles.NORTHEAST)
    if num & Tiles.WEST:
        tiles.append(Tiles.WEST)
    if num & Tiles.EAST:
        tiles.append(Tiles.EAST)
    if num & Tiles.SOUTHWEST:
        tiles.append(Tiles.SOUTHWEST)
    if num & Tiles.SOUTH:
        tiles.append(Tiles.SOUTH)
    if num & Tiles.SOUTHEAST:
        tiles.append(Tiles.SOUTHEAST)

    return tiles


def all_array_elements_in_other_array(pattern_tiles, found_tiles, num):
    if all(x in found_tiles for x in pattern_tiles):
        print(f"{num}: matched on {pattern_tiles}")
    return all(x in found_tiles for x in pattern_tiles)

if __name__ == "__main__":

    final = ["null"] * 256

    for i in range(0,256):
        tiles_for_int = get_nearby_tiles_from_int(i)
        for key, value in patterns.items():
            if all_array_elements_in_other_array(value, tiles_for_int, i):
                final[i] = key
                break

    print("Final array.")
    print("const patterns = [")
    for i, value in enumerate(final):
        print(f"\t{value},")
    print("]")