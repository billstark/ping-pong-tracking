import matplotlib as mpl
from mpl_toolkits.mplot3d import Axes3D
import numpy as np
import matplotlib.pyplot as plt

import argparse

def read_p_lst(file_name):
    points = [[float(y.strip()) for y in x.split(',')] for x in open(file_name, 'r').read().split('\n')]
    return points

def plot(p_lst):
    x, y, z = zip(*p_lst)

    mpl.rcParams['legend.fontsize'] = 10
    fig = plt.figure()
    ax = fig.gca(projection='3d')
    ax.plot(x, y, z, label='Figure')
    ax.legend()

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

