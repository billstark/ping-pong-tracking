function writePoints(points, vname, n)
    fid = fopen(strcat('out/detected_points/', vname, '_', num2str(n), '.txt'), 'wt');
    for ii = 1:size(points, 1)
        fprintf(fid, '%g\t', points(ii, :));
        fprintf(fid, '\n');
    end
    fclose(fid);
end