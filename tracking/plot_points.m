addpath('./');

close all
clear all


pic_plot = zeros(1080, 1920);
VNameList = dir('TestVideos/CAM1-*.mp4');
for vidx = 1:length(VNameList)
    vname = strcat('TestVideos/', VNameList(vidx).name);
    v = VideoReader(vname);
    v1 = VideoReader(vname);
    numberOfFrames = v1.numberOfFrames;

    averaged = double(readFrame(v));
    for i = 1 : (numberOfFrames-1)
        currentFrame = double(readFrame(v));
        averaged = ((i / (i + 1)) .* averaged) + ((1 / (i + 1)) .* currentFrame);
    end

    disp(strcat("CAM 1 Video ", vname));

    detectedPoints = detectPoints(vname, averaged);
    writePoints(detectedPoints, VNameList(vidx).name);
    ind = sub2ind(size(pic_plot), detectedPoints(:,1), detectedPoints(:,2));
    pic_plot(ind) = 255;
end

imshow(pic_plot);
print('out/CAM1.jpg', '-djpeg');


pic_plot = zeros(1080, 1920);
VNameList = dir('TestVideos/CAM2-*.mp4');
for vidx = 1:length(VNameList)
    vname = strcat('TestVideos/', VNameList(vidx).name);
    v = VideoReader(vname);
    v1 = VideoReader(vname);
    numberOfFrames = v1.numberOfFrames;

    averaged = double(readFrame(v));
    for i = 1 : (numberOfFrames-1)
        currentFrame = double(readFrame(v));
        averaged = ((i / (i + 1)) .* averaged) + ((1 / (i + 1)) .* currentFrame);
    end

    disp(strcat("CAM 2 Video ", vname));

    detectedPoints = detectPoints(vname, averaged);
    writePoints(detectedPoints, VNameList(vidx).name);
    ind = sub2ind(size(pic_plot), detectedPoints(:,1), detectedPoints(:,2));
    pic_plot(ind) = 255;
end

imshow(pic_plot);
print('out/CAM2.jpg', '-djpeg');


pic_plot = zeros(1080, 1920);
VNameList = dir('TestVideos/CAM3-*.mp4');
for vidx = 1:length(VNameList)
    vname = strcat('TestVideos/', VNameList(vidx).name);
    v = VideoReader(vname);
    v1 = VideoReader(vname);
    numberOfFrames = v1.numberOfFrames;

    averaged = double(readFrame(v));
    for i = 1 : (numberOfFrames-1)
        currentFrame = double(readFrame(v));
        averaged = ((i / (i + 1)) .* averaged) + ((1 / (i + 1)) .* currentFrame);
    end

    disp(strcat("CAM 3 Video ", vname));

    detectedPoints = detectPoints(vname, averaged);
    writePoints(detectedPoints, VNameList(vidx).name);
    ind = sub2ind(size(pic_plot), detectedPoints(:,1), detectedPoints(:,2));
    pic_plot(ind) = 255;
end

imshow(pic_plot);
print('out/CAM3.jpg', '-djpeg');
