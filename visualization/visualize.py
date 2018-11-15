import matplotlib as mpl
from mpl_toolkits.mplot3d import Axes3D
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from mpl_toolkits.mplot3d import proj3d
import math
import json

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


def read_camera_data():
    file_name = '2dto3d/Results/cameraSpecs.json'
    cam_data = json.loads(open(file_name).read())
    return cam_data


def read_p_lst(file_name):
    points = [[float(y.strip()) for y in x.split(',')] for x in open(file_name, 'r').read().strip().split('\n')]
    return points


def plot(p_lst):
    x, y, z = zip(*p_lst)

    fig = plt.figure()
    ax = fig.gca(projection='3d')
    
    for i in range(len(x)-1):
        a = Arrow3D([x[i], x[i+1]],[y[i], y[i+1]],[z[i], z[i+1]], mutation_scale=5, arrowstyle="-|>", color="r")
        ax.add_artist(a)

    
    # Plot camera data
    cam_data = read_camera_data()

    cam_pos_lst = []

    for cam in cam_data['list']:
        cam_pos = cam_data['camera_pos'][cam]
        cam_pos_lst.append(cam_pos)

        plus_I = cam_data['camera_pos_plus_vec'][cam]['plus_i']
        plus_J = cam_data['camera_pos_plus_vec'][cam]['plus_j']
        plus_K = cam_data['camera_pos_plus_vec'][cam]['plus_k']
        
        I_arrow = Arrow3D([cam_pos[0], plus_I[0]],[cam_pos[1], plus_I[1]],[cam_pos[2], plus_I[2]], mutation_scale=15, arrowstyle="-|>", color="r")
        ax.add_artist(I_arrow)
        J_arrow = Arrow3D([cam_pos[0], plus_J[0]],[cam_pos[1], plus_J[1]],[cam_pos[2], plus_J[2]], mutation_scale=15, arrowstyle="-|>", color="g")
        ax.add_artist(J_arrow)
        K_arrow = Arrow3D([cam_pos[0], plus_K[0]],[cam_pos[1], plus_K[1]],[cam_pos[2], plus_K[2]], mutation_scale=15, arrowstyle="-|>", color="b")
        ax.add_artist(K_arrow)

    cam_pos_x = [x[0] for x in cam_pos_lst]
    cam_pos_y = [x[1] for x in cam_pos_lst]
    cam_pos_z = [x[2] for x in cam_pos_lst]

    x_lst = cam_pos_x + list(x)
    y_lst = cam_pos_y + list(y)
    z_lst = cam_pos_z + list(z)

    min_x = min(x_lst)
    max_x = max(x_lst)
    min_y = min(y_lst)
    max_y = max(y_lst)
    min_z = min(z_lst)
    max_z = max(z_lst)
    mid_x = (min_x + max_x) / 2
    mid_y = (min_y + max_y) / 2
    mid_z = (min_z + max_z) / 2

    span = max([max_x-min_x, max_y-min_y, max_z-min_z])

    ax.set_xlim([mid_x-0.5*span, mid_x+0.5*span])
    ax.set_ylim([mid_y-0.5*span, mid_y+0.5*span])
    ax.set_zlim([mid_z-0.5*span, mid_z+0.5*span])

    
    plt.show()


def vector_mul(v1, v2):
    return v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2]

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("filename", help="the point data file to visualize",
        type=str)
    args = parser.parse_args()
    filename = args.filename
    points = read_p_lst(filename)
    plot(points)

