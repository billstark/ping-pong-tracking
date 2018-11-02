import matplotlib as mpl
from mpl_toolkits.mplot3d import Axes3D
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from mpl_toolkits.mplot3d import proj3d

import argparse



class Arrow3D(FancyArrowPatch):
    def __init__(self, xs, ys, zs, *args, **kwargs):
        FancyArrowPatch.__init__(self, (0,0), (0,0), *args, **kwargs)
        self._verts3d = xs, ys, zs

    def draw(self, renderer):
        xs3d, ys3d, zs3d = self._verts3d
        xs, ys, zs = proj3d.proj_transform(xs3d, ys3d, zs3d, renderer.M)
        self.set_positions((xs[0],ys[0]),(xs[1],ys[1]))
        FancyArrowPatch.draw(self, renderer)




def read_p_lst(file_name):
    points = [[float(y.strip()) for y in x.split(',')] for x in open(file_name, 'r').read().split('\n')]
    return points


def plot(p_lst):
    x, y, z = zip(*p_lst)

    mpl.rcParams['legend.fontsize'] = 10
    fig = plt.figure()
    ax = fig.gca(projection='3d')
    ax.set_xlim([min(x), max(x)])
    ax.set_ylim([min(y), max(y)])
    ax.set_zlim([min(z), max(z)])
    for i in range(len(x)-1):
        a = Arrow3D([x[i], x[i+1]],[y[i], y[i+1]],[z[i], z[i+1]], mutation_scale=20, arrowstyle="-|>", color="r")
        ax.add_artist(a)

    plt.show()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("filename", help="the point data file to visualize",
        type=str)
    args = parser.parse_args()
    filename = args.filename
    try:
        points = read_p_lst(filename)
        plot(points)
    except Exception:
        print("Invalid format of point data file {}".format(filename))

