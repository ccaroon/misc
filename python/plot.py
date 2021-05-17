# importing the required module
import matplotlib.pyplot as plt
import random_points

PRINTABLE = True

WIDTH=21.5
HEIGHT=28
COUNT=500

PLOT_WIDTH = 8.5
PLOT_HEIGHT = 11

# Set size
plt.rcParams["figure.figsize"] = (PLOT_WIDTH, PLOT_HEIGHT)

# Generate points
points = random_points.gen_random_points(
    WIDTH, HEIGHT, COUNT, 
    precision='float'
)

# Separate points by x & y
x = []
y = []
for p in points:
    x.append(p[0])
    y.append(p[1])

# Plot the points
plt.scatter(x, y, marker=".", color="black", s=5)

# Adjust for output
if PRINTABLE:
    plt.axis('off')
    plt.subplots_adjust(top=1.0, bottom=0.0, left=0.0, right=1.0)
    
    filename = F"RandomPoint-{COUNT}_{WIDTH}x{HEIGHT}.png"
    plt.savefig(filename, dpi=300)
else:
    plt.subplots_adjust(top=0.97, bottom=0.03)
    plt.title(F'{COUNT} Random Points | Grid {WIDTH}x{HEIGHT}')
    plt.xlabel('X')
    plt.ylabel('Y')


# Show the graph
plt.show()
