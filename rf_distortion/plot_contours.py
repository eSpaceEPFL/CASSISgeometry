#!/usr/bin/python2.7 
import matplotlib.pyplot as plt
import numpy as np

distorted2ideal = np.genfromtxt('ideal2distorted.txt',delimiter=',')
x = np.reshape(np.copy(distorted2ideal[:,0]),(128, 128))
y = np.reshape(np.copy(distorted2ideal[:,1]),(128, 128))
m = np.reshape(np.copy((distorted2ideal[:,2]**2 + distorted2ideal[:,3]**2)**0.5),(128, 128))
fig =plt.contour(x, y, m)
plt.clabel(fig, inline=0.5, fontsize=10)
plt.show()

plt.quiver(x, y, U, V, units='width')
