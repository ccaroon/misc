# importing the required module
import matplotlib.pyplot as plt
import random
import random_points

WIDTH=22
HEIGHT=30
COUNT=50

# Set size
# plt.rcParams["figure.figsize"] = (7.5,9.7)
plt.rcParams["figure.figsize"] = (7.5, 10)

points = random_points.gen_random_points(WIDTH, HEIGHT, COUNT, precision='float')

x = []
y = []

# one
for p in points:
    print(p)
    x.append(p[0])
    y.append(p[1])

# two
# for i in range(0,COUNT):
#     x.append(random.random()*WIDTH)
#     y.append(random.random()*HEIGHT)

# print(x)
# print(y)
# Plot the points
plt.scatter(x, y, marker=".", color="black", s=5)

# Margins
plt.subplots_adjust(top=.97, bottom=0.05)

# Title & Axis Lables
plt.title(F'{COUNT} Random Points | Grid {WIDTH}x{HEIGHT}')
plt.xlabel('X')
plt.ylabel('Y')

# Show the graph
plt.show()
