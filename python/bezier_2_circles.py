"""

    Attempt at transforming a Bezier curve to a series of circular arcs

"""
from line_work import *
from bezier import Bezier
import numpy as np

def bezier_2_circles(p1, p2, p3, p4, scale_factor):
    """
    This function converts a provided cubic bezier curve into a series of G-Code
    executable circular interpolations
    When called, this function will directly print to screen the necessary G-Code
    commands to draw the provided bezier curve
    """
    # Create Bezier Curve from Points
    curve = Bezier(p1, p2, p3, p4)

    # Set current Bezier curve to the curve we receive
    current_bezier = curve

    # Set inflexion flag to 0
    curvature_changed = 0
    # Create buffer to store all pushed Bezier curve segments
    bezier_buffer = []

    # Define error threshold to determine how close the estimates should be
    error_threshold = 0.0000001

    # Continue until we go through the entire curve
    while(True):
        # Find the first inflexion point on the curve
        if current_bezier.get_inflexion_point() == -1:
            # If no inflexion point found on curve, skip this step
            pass
        else:
            if curvature_changed:
                # Ignore future inflexion detections
                pass
            else:
                # If an inflexion point was found
                # Calculate the split point of the Bezier at this found inflexion
                [b1, b2] = current_bezier.split_bezier(current_bezier.get_inflexion_point())
                # Set the first segment to this
                current_bezier = b1
                # Push the remaining curve onto the buffer
                bezier_buffer.append(b2)
                # Indicate an inflexion occurred by setting the flag to 1
                curvature_changed = 1

        # Determine approximate angle of the arc
        _angle = current_bezier.get_angle()
        # Determine what angular range the curve segment falls into
        if abs(_angle) <= np.pi/2:
            pass
        elif abs(_angle) <= np.pi:
            # Split the curve in half
            [b1, b2] = current_bezier.split_bezier(0.5)
            # Set first section to the current arc
            current_bezier = b1
            # Push remainder onto the buffer
            bezier_buffer.append(b2)
        else:
            # Loop until curve section is under 90 degrees
            t = 0.5
            while True:
                [b1, b2] = current_bezier.split_bezier(t)
                # Continue dividing until the first segment is under 90 degrees
                if abs(b1.get_angle()) < np.pi/2:
                    # If first section is under 90 degrees, break from loop
                    break
                else:
                    t *= 0.5
            # Set current bezier to this section
            current_bezier = b1
            bezier_buffer.append(b2)

        # ----- Approximate the Bezier Segment -----
        # Get intersection point of the two tangents
        A = generate_line(current_bezier.p1, current_bezier.p2)
        B = generate_line(current_bezier.p3, current_bezier.p4)

        # Determine the incentre points of lines A and B
        X = find_intersection(A,B)
        if X == None and len(bezier_buffer) > 0:
            # Just move onto the next section for now
            current_bezier = bezier_buffer.pop(len(bezier_buffer) - 1)
        elif X == None and len(bezier_buffer) == 0:
            # CHECK WHY THE BUFFER BECOMES EMPTY!!
            # If there's no intersection, skip
            print bezier_buffer
            break
        else:
            # Find the incentre of points 1,4 and X
            G = find_incentre(current_bezier.p1, current_bezier.p4, X)
            # Create a circle from points 1,4 and G, find the centre point
            centre = generate_circle(current_bezier.p1, current_bezier.p4, G)

            # Get the radius of the generated circle
            radius = np.linalg.norm([current_bezier.p1.x - centre.x, current_bezier.p1.y - centre.y])
            # Define two test points to determine the error of the arc to the curve
            # Chose 25% and 75% along the curve for good estimates
            tp_1 = current_bezier.get_point(0.25)
            tp_2 = current_bezier.get_point(0.75)
            # Determine the average distance of the Bezier endpoints to the circle centre
            distance_1 = np.linalg.norm([tp_1.x - centre.x, tp_1.y - centre.y])
            distance_2 = np.linalg.norm([tp_2.x - centre.x, tp_2.y - centre.y])
            # Get sum of squares of the two errors
            error = (radius - distance_1)*(radius - distance_1) + (radius - distance_2)*(radius - distance_2)
            if error > error_threshold:
                # Split the Curve in Half
                [b1, b2] = current_bezier.split_bezier(0.5)
                # Push the other half to the buffer
                current_bezier = b1
                bezier_buffer.append(b2)
            else:
                # Determine if we need to move around the circle in a clockwise or anticlockwise direction

                # Determine the chord P1 to P4
                L = generate_line(current_bezier.p1, current_bezier.p4)
                # Assess direction of L
                if current_bezier.p4.x >= current_bezier.p1.x:
                    if centre.y < -(L[0] * centre.x + L[2])/L[1]:
                        # If circle centre is below L, move in clockwise fashion
                        direction = 2
                    else:
                        direction = 3
                else:
                    # If line points to the left
                    if centre.y < -(L[0]*centre.x + L[2])/L[1]:
                        # Move in an anticlockwise direction
                        direction = 3
                    else:
                        direction = 2

                # Return the circular command with 6 decimal place accuracy
                print "G{0:d} ".format(direction) + \
                      "X{0:.6f} ".format(current_bezier.p4.x * scale_factor) + \
                      "Y{0:.6f} ".format(current_bezier.p4.y * scale_factor) + \
                      "I{0:.6f} ".format((centre.x - current_bezier.p1.x) * scale_factor) + \
                      "J{0:.6f}".format((centre.y - current_bezier.p1.y)* scale_factor)

                if len(bezier_buffer) == 0:
                    break
                else:
                    # Get the next Bezier segment from the buffer to work on in the next loop
                    current_bezier = bezier_buffer.pop(len(bezier_buffer) - 1)
