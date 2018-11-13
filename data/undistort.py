pos_list = open('ball_pos_list.txt').read().strip().split('\n')
pos_list = [x.strip().split('\t') for x in pos_list]

pos_dict = {}
for pos in pos_list:
    if pos[0] not in pos_dict:
        pos_dict[pos[0]] = []
    pos_dict[pos[0]].append([int(pos[1])-1, float(pos[2]), float(pos[3])])


for key in pos_dict:
    pos_dict[key] = sorted(pos_dict[key], key=lambda x: x[0])


def distort_xy(u, v, cam_num):
    k_lst = [[-0.27130810574978376, 0.12353492396888929, -0.034139519690971919, 870.14531487461625, 949.42001822880479, 870.14531487461625, 487.20049852775117],
             [-0.28161923440814401, 0.13207856151552402, -0.039955130224944388, 893.34367240024267, 949.96816131377727, 893.34367240024267, 546.79562177577259],
             [-0.29393100306875553, 0.20417834932193116, -0.10715409751739460, 872.90852997159800, 944.45161471037636, 872.90852997159800, 564.47334036925656]]
    k1, k2, k3, fx, cx, fy, cy = k_lst[cam_num]

    x = (u-cx)/fx
    y = (u-cy)/fy
    r2 = x**2 + y**2
    dist = 1 + k1*r2 + k2*r2**2 + k3*r2**3
    xp = x*dist
    yp = y*dist

    up = xp*fx + cx
    vp = yp*fy + cy
    return up, vp
