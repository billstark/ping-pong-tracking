function writePoints(points, sub_folder, vname, n)
    fid = fopen(strcat('ping-pong-tracking/data/', sub_folder, '/', vname, '_', num2str(n), '.txt'), 'wt');
    for ii = 1:size(points, 1)
        fprintf(fid, '%g\t', points(ii, :));
        fprintf(fid, '\n');
    end
    fclose(fid);
end