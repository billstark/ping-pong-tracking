addpath('./');

close all
clear all

plot_camera_videos('CAM1', [553 112 846 346]);
plot_camera_videos('CAM2', [589 98 898 488]);
plot_camera_videos('CAM3', [457 228 886 416]);


function plot_camera_videos(prefix, crop)
    pic_plot = zeros(1080, 1920);
    VNameList = dir(strcat('TestVideos/', prefix, '*.mp4'));
    for vidx = 1:length(VNameList)
        vname = strcat('TestVideos/', VNameList(vidx).name);
        v = VideoReader(vname);
        v1 = VideoReader(vname);
        numberOfFrames = v1.numberOfFrames;

        averaged = double(imcrop(readFrame(v), crop));
        for i = 1 : (numberOfFrames-1)
            currentFrame = double(imcrop(readFrame(v), crop));
            averaged = ((i / (i + 1)) .* averaged) + ((1 / (i + 1)) .* currentFrame);
        end

        detectedPoints = detectPoints(vname, uint8(averaged), crop);
        ind = sub2ind(size(pic_plot), detectedPoints(:,2), detectedPoints(:,1));
        pic_plot(ind) = 255;
    end

    imshow(pic_plot);
    print(strcat('out/', prefix, '.jpg'), '-djpeg');
end