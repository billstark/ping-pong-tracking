function showPoints(name, n_frame)
    vname = strcat('TestVideos/', name, '.mp4');
    fname = strcat('ping-pong-tracking/data/detected_points/', name, '_', num2str(n_frame), '.txt');
    points = readPoints(fname);
    v = VideoReader(vname);
    for i = 1:n_frame
        frame = readFrame(v);
    end
    
    imshow(frame);
    
    for i = 1:size(points, 1)
        x = points(i, 1);
        y = points(i, 2);
        rectangle('Position', [x - 6, y - 6, 13, 13], 'EdgeColor', 'r', 'LineWidth', 1)
    end
end