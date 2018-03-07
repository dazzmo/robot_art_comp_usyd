from line_work import Point
from os import path
from xml.dom import minidom
from bezier_2_circles import bezier_2_circles

# Get project base location
_basepath = path.dirname(__file__)
_filepath = path.abspath(path.join(_basepath,'dog.svg'))
# Convert SVG file to achieve a series of path strings
doc = minidom.parse(_filepath)  # parseString also exists
path_strings = [path.getAttribute('d') for path
                in doc.getElementsByTagName('path')]
doc.unlink()

## There's DOUBLING OF G1 commands after the circle commands

# Create SCALE_FACTOR to determine the scaling of the overall GCODE output
SCALE_FACTOR = 100

# Create 4 Points
p1 = Point(0,0)
p2 = Point(0,0)
p3 = Point(0,0)
p4 = Point(0,0)

# Establish a Start Point for Each Curve Section
start_point = Point(0,0)
start_point_flag = 0

# Iterate through the path strings
for element in path_strings:
    # Look For Specific Codes

    for i in range(0, len(element)):
        if element[i] == 'M':
            """
            M: Absolute Move To Command
            """
            # Skip the 'M'
            i += 1
            x = []
            y = []
            # Get X value
            while element[i] in ['0','1','2','3','4','5','6','7','8','9','-','.',' ']:
                x.append(element[i])
                i += 1
            # Skip the ',' character
            i += 1
            # Get Y value
            while element[i] in ['0','1','2','3','4','5','6','7','8','9','-','.',' ']:
                y.append(element[i])
                i += 1
            # Set Point 4 as the Starting Point for M codes (to count as the last point of the operation)
            p4.x = float(''.join(x))
            p4.y = float(''.join(y))

            if start_point_flag == 0:
                # Set the Start Point of the Subcurve to This Point
                start_point.x = p4.x
                start_point.y = p4.y
                # Set the flag
                start_point_flag = 1


            # Go to the ink place
            print "M3 S20"
            print "G0 X0 Y20"
            print "M3 S50"
            print "M3 S20"
            print "G0 X" + str(p4.x * SCALE_FACTOR) + " Y" + str(p4.y * SCALE_FACTOR)
            print "M3 S50"
        if element[i] == 'c':
            """
            c: Relative Cubic Bezier Curve Command
            """
            # Skip the 'c'
            i += 1
            c_values = []
            # Get string of C points
            while element[i] in ['0','1','2','3','4','5','6','7','8','9','-','.',',',' ']:
                c_values.append(element[i])
                i += 1
            j = 1
            # Go through all the points except the first
            while j < len(c_values):
                if c_values[j] == '-' and c_values[j - 1] != ',':
                    # Place a ',' in front of the '-'
                    c_values.insert(j, ',')
                    j += 2
                if c_values[j] == ' ':
                    c_values[j] = ','
                j += 1
            # Receive the points needed
            c_values = ''.join(c_values).split(',')
            # Convert the points to Bezier notation
            p1.x = p4.x
            p1.y = p4.y
            p2.x = p4.x + float(c_values[0])
            p2.y = p4.y + float(c_values[1])
            p3.x = p4.x + float(c_values[2])
            p3.y = p4.y + float(c_values[3])
            p4.x = p4.x + float(c_values[4])
            p4.y = p4.y + float(c_values[5])

            bezier_2_circles(p1, p2, p3, p4, SCALE_FACTOR)

            if start_point_flag == 0:
                # Set the Start Point of the Subcurve to This Point
                start_point.x = p1.x
                start_point.y = p1.y
                # Set the flag
                start_point_flag = 1

        if element[i] == 'C':
            """
            C: Absolute Cubic Bezier Curve Command
            """
            i += 1
            c_values = []
            # Get string of C points
            while element[i] in ['0','1','2','3','4','5','6','7','8','9','-','.',',',' ']:
                c_values.append(element[i])
                i += 1
            j = 1
            # Go through all the points except the first
            while j < len(c_values):
                if c_values[j] == '-' and c_values[j - 1] != ',':
                    c_values.insert(j, ',')
                    j += 2
                if c_values[j] == ' ':
                    c_values[j] = ','
                j += 1
            # Receive the points needed
            c_values = ''.join(c_values).split(',')
            # Convert the points to Bezier notation
            p1.x = p4.x
            p1.y = p4.y
            p2.x = float(c_values[0])
            p2.y = float(c_values[1])
            p3.x = float(c_values[2])
            p3.y = float(c_values[3])
            p4.x = float(c_values[4])
            p4.y = float(c_values[5])

            bezier_2_circles(p1, p2, p3, p4, SCALE_FACTOR)

            if not start_point_flag:
                # Set the Start Point of the Subcurve to This Point
                start_point.x = p1.x
                start_point.y = p1.y
                # Set the flag
                start_point_flag = 1

        if element[i] == 's':
            """
            s: Relative Cubic Bezier Curve Command
            """
            i += 1
            c_values = []
            # Get string of C points
            while element[i] in ['0','1','2','3','4','5','6','7','8','9','-','.',',',' ']:
                c_values.append(element[i])
                i += 1
            j = 1
            # Go through all the points except the first
            while j < len(c_values):
                if c_values[j] == '-' and c_values[j - 1] != ',':
                    c_values.insert(j, ',')
                    j += 2
                if c_values[j] == ' ':
                    c_values.pop(j)
                j += 1
            # Receive the points needed
            c_values = ''.join(c_values).split(',')
            # Convert the points to Bezier notation
            p1.x = p4.x
            p1.y = p4.y
            p2.x = 2 * p4.x - p3.x
            p2.y = 2 * p4.y - p3.y
            p3.x = float(c_values[0])
            p3.y = float(c_values[1])
            p4.x = float(c_values[2])
            p4.y = float(c_values[3])

            bezier_2_circles(p1, p2, p3, p4, SCALE_FACTOR)

        if element[i] == 'l':
            """
            l: Relative Line Movement
            """
            i += 1
            l_values = []
            # Get string of C points
            while element[i] in ['0','1','2','3','4','5','6','7','8','9','-','.',',',' ']:
                l_values.append(element[i])
                i += 1
            # Index through the newly acquired string
            j = 1
            # Go through all the points except the first
            while j < len(l_values):
                if l_values[j] == '-' and l_values[j - 1] != ',':
                    # Place a ',' before the '-'
                    l_values.insert(j, ',')
                    # Increase index by 2 to move past the ',-'
                    j += 2
                if l_values[j] == ' ':
                    # Remove spaces in the string
                    l_values.pop(j)
                j += 1
            # Receive the points needed
            l_values = ''.join(l_values).split(',')

            # Destination Point
            p4.x = p4.x + float(l_values[0])
            p4.y = p4.y + float(l_values[1])

            print "G1 X" + str(p4.x * SCALE_FACTOR) + " Y" + str(p4.y * SCALE_FACTOR)

        if element[i] == 'L':
            """
            L: Absolute Line Movement
            """
            # Skip the 'L' character
            i += 1
            l_values = []
            # Get string of C points
            while element[i] in ['0','1','2','3','4','5','6','7','8','9','-','.',',',' ']:
                l_values.append(element[i])
                i += 1
            j = 1
            # Go through all the points except the first
            while j < len(l_values):
                if l_values[j] == '-' and l_values[j - 1] != ',':
                    l_values.insert(j, ',')
                    j += 2
                if l_values[j] == ' ':
                    l_values.pop(j)
                j += 1
            # Receive the points needed
            l_values = ''.join(l_values).split(',')

            # Destination Point
            p4.x = float(l_values[0])
            p4.y = float(l_values[1])

            print "G1 X" + str(p4.x * SCALE_FACTOR) + " Y" + str(p4.y * SCALE_FACTOR)

        if element[i] == 'z' or element[i] == 'Z':
            print "G1 X" + str(start_point.x * SCALE_FACTOR) + " Y" + str(start_point.y * SCALE_FACTOR)
            # Reset the starting point flag
            start_point_flag = 0
            i += 1

    start_point_flag = 0
