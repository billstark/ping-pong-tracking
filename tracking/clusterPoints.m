addpath('./');

close all;
clear all;

calc_ball_pos();

function calc_ball_pos()
    FNameList = dir('ping-pong-tracking/data/detected_points/*.txt');
    fid = fopen('ping-pong-tracking/data/ball_pos_list.txt', 'wt');
    for fidx = 1:length(FNameList)
        filename = FNameList(fidx).name;
        fname = strcat('ping-pong-tracking/data/detected_points/', filename);
        points = readPoints(fname);
        dists = squareform(pdist(points));
        near_points = dists<80;
        [x, y]=find(near_points);
        pairs = sort([x y], 2);
        arrs=[];
        for i=1:size(pairs, 1)
            pair = pairs(i, :);
            added = false;
            for j=1:size(arrs, 1)
                if ismember(pair(1), arrs(j, :))
                    arrs(j, size(arrs, 2)+1) = pair(2);
                    added = true;
                end
            end
            if ~added
                arrs_height = size(arrs, 1)+1;
                arrs(arrs_height, 1) = pair(1);
                arrs(arrs_height, 2) = pair(2);
            end
        end

        min_num_points = 5;
        selected_arr = [];
        for i=1:size(arrs, 1)
            if size(find(unique(arrs(i, :))), 2) > min_num_points
                selected_arr = unique(arrs(i, :));
                min_num_points = size(selected_arr, 2);
            end
        end

        if selected_arr
            selected_points = points(selected_arr, :);
            ball_pos = mean(selected_points);
            file_head = strsplit(filename, '.');
            file_head = strsplit(file_head{1}, '_');
            fprintf(fid, file_head{1});
            fprintf(fid, '\t');
            fprintf(fid, file_head{2});
            fprintf(fid, '\t');
            fprintf(fid, '%g\t', ball_pos);
            fprintf(fid, '\n');
        end

    end
    fclose(fid);
end
