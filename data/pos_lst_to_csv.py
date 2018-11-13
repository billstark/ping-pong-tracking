import csv

pos_list = open('data/ball_pos_list.txt').read().strip().split('\n')
pos_list = [x.strip().split('\t') for x in pos_list]

pos_dict = {}
for pos in pos_list:
    if pos[0] not in pos_dict:
        pos_dict[pos[0]] = []
    pos_dict[pos[0]].append([int(pos[1])-1, float(pos[2]), float(pos[3])])


for key in pos_dict:
    lst = pos_dict[key]
    fr_n = max(lst, key=lambda x: x[0])[0] + 1
    pos_arr = [[0, 0]] * fr_n
    for item in lst:
        pos_arr[item[0]] = item[1:]

    with open('2dto3d/Tracking/' + key + '.csv', 'wb') as csvfile:
        writer = csv.writer(csvfile, delimiter=',')
        writer.writerow(['frame', 'x', 'y'])
    
        for fr, pos in enumerate(pos_arr):
            writer.writerow([fr, pos[0], pos[1]])


