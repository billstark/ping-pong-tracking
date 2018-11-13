import matplotlib as mpl
from mpl_toolkits.mplot3d import Axes3D
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from mpl_toolkits.mplot3d import proj3d
import math

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
    file_name = '2dto3d/Results/cameraPos.csv'
    pos_data = [[float(y) for y in x.split(',')] for x in open(file_name, 'r').read().strip().split('\n')]
    cam_count = len(pos_data[0])
    cam_data_lst = []
    for i in range(cam_count):
        cam_data = {}
        cam_data['pos'] = [pos_data[0][i], pos_data[1][i], pos_data[2][i]]
        cam_data['R'] = [[pos_data[3][i], pos_data[4][i], pos_data[5][i]],
                         [pos_data[6][i], pos_data[7][i], pos_data[8][i]],
                         [pos_data[9][i], pos_data[10][i], pos_data[11][i]]]
        cam_data_lst.append(cam_data)
    return cam_data_lst


def R_to_euler_angles(R):
    R = np.array(R)
    sy = math.sqrt(R[0,0] * R[0,0] +  R[1,0] * R[1,0])
     
    singular = sy < 1e-6
 
    if  not singular :
        x = math.atan2(R[2,1] , R[2,2])
        y = math.atan2(-R[2,0], sy)
        z = math.atan2(R[1,0], R[0,0])
    else :
        x = math.atan2(-R[1,2], R[1,1])
        y = math.atan2(-R[2,0], sy)
        z = 0
 
    return [x, y, z]


def read_p_lst(file_name):
    points = [[float(y.strip()) for y in x.split(',')] for x in open(file_name, 'r').read().strip().split('\n')]
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
        a = Arrow3D([x[i], x[i+1]],[y[i], y[i+1]],[z[i], z[i+1]], mutation_scale=5, arrowstyle="->", color="r")
        ax.add_artist(a)

    
    # Plot camera data
    cam_data = read_camera_data()
    for cam in cam_data:
        cam_pos = cam['pos']
        R = cam['R']
        rx, ry, rz = R_to_euler_angles(R)
        



    plt.show()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("filename", help="the point data file to visualize",
        type=str)
    args = parser.parse_args()
    filename = args.filename
    points = read_p_lst(filename)
    plot(points)

