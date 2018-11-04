function points = readPoints(fname)
    fid = fopen(fname, 'r');
    sizeA = [2 Inf];
    A = fscanf(fid, '%g\t', sizeA);
    points = A';
    fclose(fid);
end