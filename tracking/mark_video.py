import os
import cv2
import shutil

v_name_lst = [x.split('.')[0] for x in os.listdir('../TestVideos/')]


def mark(vname):
    v_filepath = os.path.join('../TestVideos/', vname) + '.mp4'
    p_filepath = os.path.join('2dto3d/Tracking/', vname) + '.csv'
    v_point_data = [[int(round(float(y))) if y is not '' else None for y in x.split(',')[1:]] for x in open(p_filepath).read().splitlines()[1:]]
    vidcap = cv2.VideoCapture(v_filepath)
    fps = vidcap.get(cv2.CAP_PROP_FPS)
    width = int(vidcap.get(3))
    height = int(vidcap.get(4))
    success, image = vidcap.read()
    count = 0

    if not os.path.exists('temp_out_img'):
        os.mkdir('temp_out_img')

    if not os.path.exists('presentation/marked_videos'):
        os.mkdir('presentation/marked_videos')

    # Process video and save frames as images
    while success and count < len(v_point_data):
        x = v_point_data[count][0]
        y = v_point_data[count][1]
        if x and y:
            cv2.line(image, (x, 0), (x, height), (0, 0, 255), 2)
            cv2.line(image, (0, y), (width, y), (0, 0, 255), 2)
        cv2.imwrite("temp_out_img/%d.jpg" % count, image)
        success,image = vidcap.read()
        print('Read a new frame: {}, {}'.format(count, success))
        count += 1

    # Make images to video
    image_folder = 'temp_out_img'
    video_name = os.path.join('presentation/marked_videos', vname) + '.mp4'

    images = sorted([img for img in os.listdir(image_folder) if img.endswith(".jpg")], key=lambda x: int(x.split('.')[0]))
    frame = cv2.imread(os.path.join(image_folder, images[0]))

    video = cv2.VideoWriter(video_name, -1, fps, (width,height))

    for image in images:
        video.write(cv2.imread(os.path.join(image_folder, image)))

    cv2.destroyAllWindows()
    video.release()

    shutil.rmtree('temp_out_img')

    

    return p_filepath

for vname in v_name_lst:
    mark(vname)