import numpy as np

## Tidy this up at home

class Point():
    """
    Create class for simple cartesian points
    """
    def __init__(self, x, y):
        self.x = x
        self.y = y

def generate_line(point_1, point_2):
    """
    Creates a 2D line which goes through point_1 and
    point_2. Expresses the line in general form and
    outputs a column vector with the 3 coefficients
    """
    A = point_1.y - point_2.y
    B = point_2.x - point_1.x
    C = point_1.y * B + point_1.x * A
    return np.matrix([[A],[B],[-C]])

def perpendicular_bisector(point_1, point_2):
    """
    Creates the perpendicular bisector between point_1 and point_2
    """
    A = 2 * (point_2.x - point_1.x)
    B = 2 * (point_2.y - point_1.y)
    C = (point_1.y - point_2.y) * (point_1.y + point_2.y) + \
        (point_1.x - point_2.x) * (point_1.x + point_2.x)
    return np.matrix([[A],[B],[C]])

def find_intersection(coefs_1, coefs_2):
    """
    Using two line coefficient vectors, this method will find the intersection
    point of the two
    """
    # Form the necessary matrices
    A = np.matrix([[coefs_1[0,0], coefs_1[1,0]], [coefs_2[0,0], coefs_2[1,0]]])
    B = np.matrix([[coefs_1[2,0]],[coefs_2[2,0]]])
    if np.linalg.det(A) == 0:
        return None
    else:
        _intersection = -np.linalg.inv(A) * B
        return Point(_intersection[0,0], _intersection[1,0])

def generate_circle(point_1, point_2, point_3):
    """
    Given 3 points, this routine will determine the centre of the circle which
    passes through all of them
    """
    # Need to check if points are collinear, if so a circle can't exist
    line_1 = perpendicular_bisector(point_1, point_2)
    line_2 = perpendicular_bisector(point_2, point_3)
    # Find intersection of the two lines
    return find_intersection(line_1, line_2)

def find_incentre(point_1, point_2, point_3):
    """
    Finds the location of the incentre point of 3 given points
    """
    _a = np.linalg.norm([point_1.x - point_2.x, point_1.y - point_2.y])
    _b = np.linalg.norm([point_2.x - point_3.x, point_2.y - point_3.y])
    _c = np.linalg.norm([point_1.x - point_3.x, point_1.y - point_3.y])
    _p = _a + _b + _c

    centre_x = (_a * point_3.x + _b * point_1.x + _c * point_2.x)/ _p
    centre_y = (_a * point_3.y + _b * point_1.y + _c * point_2.y)/ _p

    return Point(centre_x, centre_y)
