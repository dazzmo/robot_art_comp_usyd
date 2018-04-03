import numpy as np
from line_work import Point

class Bezier():

    def __init__(self, p1, p2, p3, p4):
        """
        Get each point and store it via it's enumerated value
        """
        # Store the 4 control points for the cubic Bezier
        self.p1 = p1
        self.p2 = p2
        self.p3 = p3
        self.p4 = p4

    def get_point(self, t):
        """
        Returns the x,y position of the Bezier at the given parametric value t
        """
        # Determine t matrix
        t_matrix = np.array([1, t, t*t, t*t*t])

        # Bezier curve matrix
        M = np.array([[1, 0, 0, 0],
                      [-3, 3, 0, 0],
                      [3, -6, 3, 0],
                      [-1, 3, -3, 1]])

        # Generate the dot product of the two matrices
        A = np.dot(t_matrix, M)

        # Create vectors for the X and Y coordinates
        points_x = np.array([self.p1.x,
                             self.p2.x,
                             self.p3.x,
                             self.p4.x])

        points_y = np.array([self.p1.y,
                             self.p2.y,
                             self.p3.y,
                             self.p4.y])

        # Return the point given at t as a 'Point' object
        return Point(np.dot(A, points_x), np.dot(A, points_y))

    def split_bezier(self, k):
        """
        Given a standard cubic bezier curve, this function will split the curve at
        point t = k. This function then returns two Bezier curves which are
        respectively the first and second curves divided by the split point
        """
        # Check if k is between the parametric range
        if k > 1 or k < 0:
            return
        # Perform the splitting
        # Create matrix to determine the first split t = [0, k]
        A = np.array([[1, 0, 0, 0],
                       [-(k-1), k, 0, 0],
                       [(k-1)*(k-1), -2*(k-1)*k, k*k, 0],
                       [-(k-1)*(k-1)*(k-1), 3*(k-1)*(k-1)*k, -3*(k-1)*k*k, k*k*k]])

        # Turn matrix into a list for easier manipulation
        _temp_matrix = A.tolist()

        # Create the matrix to determine the second split t= [k,1]
        B = np.array([_temp_matrix[3],
                     [0] + _temp_matrix[2][0:3],
                     [0, 0] + _temp_matrix[1][0:2],
                     [0, 0, 0, 1]])

        # Create the matrix which maps the given Bezier points to the split points
        points_x = np.array([self.p1.x,
                             self.p2.x,
                             self.p3.x,
                             self.p4.x])

        points_y = np.array([self.p1.y,
                             self.p2.y,
                             self.p3.y,
                             self.p4.y])

        # Solve for the point vectors and return them as a 4 x 2 matrix
        bezier_points = np.array([np.transpose(np.dot(A, points_x)),
                                  np.transpose(np.dot(A, points_y)),
                                  np.transpose(np.dot(B, points_x)),
                                  np.transpose(np.dot(B, points_y))])

        # Return a list of two bezier curves
        return [Bezier(
                            Point(bezier_points[0][0], bezier_points[1][0]),
                            Point(bezier_points[0][1], bezier_points[1][1]),
                            Point(bezier_points[0][2], bezier_points[1][2]),
                            Point(bezier_points[0][3], bezier_points[1][3])
                        ),
                Bezier(
                            Point(bezier_points[2][0], bezier_points[3][0]),
                            Point(bezier_points[2][1], bezier_points[3][1]),
                            Point(bezier_points[2][2], bezier_points[3][2]),
                            Point(bezier_points[2][3], bezier_points[3][3])
                        )]

    def get_inflexion_point(self):
        """
        Locates the t positions of the inflexion points of the Bezier curve, and
        returns the first appropriate t value if an inflexion exists. If one
        doesn't exist in t = [0,1], then this will return -1
        """
        # Firstly, we must align the Bezier curve
        # Translate such that P1 = (0,0)
        # Create vectors of the new translated points
        p1_align = np.array([[0],
                             [0]])
        p2_align = np.array([[self.p2.x - self.p1.x],
                             [self.p2.y - self.p1.y]])
        p3_align = np.array([[self.p3.x - self.p1.x],
                             [self.p3.y - self.p1.y]])
        p4_align = np.array([[self.p4.x - self.p1.x],
                             [self.p4.y - self.p1.y]])
        # Rotate the curve to achieve P4.y = 0
        # Get the required angle
        if p4_align[0][0] == 0 and p4_align[1][0] > 0:
            _theta = np.pi/2
        elif p4_align[0][0] == 0 and p4_align[1][0] < 0:
            _theta = -np.pi/2
        elif p4_align[0][0] == 0 and p4_align[1][0] == 0:
            _theta = 0
        else:
            _theta = -np.arctan(p4_align[1][0]/p4_align[0][0])
        # Rotate the points using the following matrix
        _rotation_matrix = np.array([[np.cos(_theta), -np.sin(_theta)],
                                     [np.sin(_theta), np.cos(_theta)]])

        p2_align = np.dot(_rotation_matrix, p2_align)
        p3_align = np.dot(_rotation_matrix, p3_align)
        p4_align = np.dot(_rotation_matrix, p4_align)

        # All points are now properly aligned and rotated
        # a = p3.x * p2.y
        a = p3_align[0][0] * p2_align[1][0]
        b = p4_align[0][0] * p2_align[1][0]
        c = p2_align[0][0] * p3_align[1][0]
        d = p4_align[0][0] * p3_align[1][0]

        x = 18 * (-3*a + 2*b + 3*c - d)
        y = 18 * (3*a - b - 3*c)
        z = 18 * (c - a)

        discriminant = y * y - 4 * x * z

        if discriminant < 0:
            # Return -1 if non-real t exist
            return -1
        elif x == 0:
            return -1
        else:
            discriminant_sqrt = np.sqrt(discriminant)
            # Determine t_1 first and see if it qualifies as the inflexion point
            t_1 = 0.5 * (-y - discriminant_sqrt) / x
            if (t_1 >= 0 and t_1 <= 1):
                return t_1
            # If t_1 doesn't qualify, then work out t_2
            t_2 = 0.5 * (-y + discriminant_sqrt) / x
            if (t_2 >= 0 and t_2 <= 1):
                return t_2
            else:
                # If neither satisfy the range [0,1], return -1
                return -1

    def _get_tangent(self, t):

        # In the cases the control points overlap (e.g. P1 = P2), we need to
        # account for this to avoid a 0 derivative vector (so as a quick-fix we're
        # just moving the second point a little over)

        if self.p1.x == self.p2.x and self.p1.y == self.p2.y:
            # Offset P2 a little bit depending on the direction of P4
            if self.p4.x <= self.p1.x:
                self.p2.x -= 0.0001
            else:
                self.p2.x += 0.0001
            if self.p4.y <= self.p1.y:
                self.p2.y -= 0.0001
            else:
                self.p2.y += 0.0001

        if self.p3.x == self.p4.x and self.p3.y == self.p4.y:
            # Offset P3 a little bit depending on the direction of P4 relative to P1
            if self.p4.x <= self.p1.x:
                self.p3.x += 0.0001
            else:
                self.p3.x -= 0.0001
            if self.p4.y <= self.p1.y:
                self.p3.y += 0.0001
            else:
                self.p3.y -= 0.0001

        if self.p4.x == self.p1.x and self.p4.y == self.p1.y:
            # Offset P1 a little bit
            self.p1.x += 0.0001
            self.p1.y += 0.0001

        # Get derivative at point t for both X and Y
        t_matrix = np.array([1, t, t*t])
        # Derivative matrix
        M = np.array([[1, 0, 0],
                      [-2, 2, 0],
                      [1, -2, 1]])

        # Matrix of weights for the Bezier curve's first derivative
        W_x = np.array([[3*(self.p2.x - self.p1.x)],
                        [3*(self.p3.x - self.p2.x)],
                        [3*(self.p4.x - self.p3.x)]])

        W_y = np.array([[3*(self.p2.y - self.p1.y)],
                        [3*(self.p3.y - self.p2.y)],
                        [3*(self.p4.y - self.p3.y)]])

        temp_matrix = np.dot(t_matrix, M)
        # Determine the X and Y components of the derivative at point t
        derivative_x = np.dot(temp_matrix, W_x)[0]
        derivative_y = np.dot(temp_matrix, W_y)[0]

        d = np.linalg.norm([derivative_x, derivative_y])

        if d == 0:
            return np.array([[0],[0]])
        else:
            return np.array([[derivative_x/d],
                             [derivative_y/d]])

    def get_angle(self):
        # Get the angle between the tangents at the endpoints of the curve (assuming
        # get_tangent() returns unit vectors)
        _dot_product = np.dot(np.transpose(self._get_tangent(0)),self._get_tangent(1))
        # Errors do occur where the dot product exceeds +1 or -1
        if _dot_product > 1:
            _angle = np.arccos(1)
        elif _dot_product < -1:
            _angle = np.arccos(-1)
        else:
            _angle = np.arccos(np.dot(np.transpose(self._get_tangent(0)),self._get_tangent(1)))
        return _angle
