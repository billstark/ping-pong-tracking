% ===============================================================
% Compute the 3D trajectory of the table tennis balls
% ===============================================================

% Extrinsic parameters (i.e. R and t) for each of the 3 cameras
% Camera 1:
R1 = zeros(3,3);
R1(1,:) = [9.6428667991264605e-01 -2.6484969138677328e-01 -2.4165916859785336e-03];
R1(2,:) = [-8.9795446022112396e-02 -3.1832382771611223e-01 -9.4371961862719200e-01];
R1(3,:) = [2.4917459103354755e-01 9.1023325674273947e-01 -3.3073772313234923e-01];
t1 = [1.3305621037591506e-01; -2.5319578738559911e-01; 2.2444637695699150e+00];
t1 = -inv(R1) * t1;

% camera 1 orientation
i1 = R1(1,:);
j1 = R1(2,:);
k1 = R1(3,:);

% Camera 2:
R2 = zeros(3,3);
R2(1,:) = [9.4962278945631540e-01 3.1338395965783683e-01 -2.6554800661627576e-03];
R2(2,:) = [1.1546856489995427e-01 -3.5774736713426591e-01 -9.2665194751235791e-01];
R2(3,:) = [-2.9134784753821596e-01 8.7966318277945221e-01 -3.7591104878304971e-01];
t2 = [-4.2633372670025989e-02; -3.5441906393933242e-01; 2.2750378317324982e+00];
t2 = -inv(R2)*t2;

% camera 2 orientation
i2 = R2(1,:);
j2 = R2(2,:);
k2 = R2(3,:);

% Camera 3:
R3 = zeros(3,3);
R3(1,:) = [-9.9541881789113029e-01 3.8473906154401757e-02 -8.7527912881817604e-02];
R3(2,:) = [9.1201836523849486e-02 6.5687400820094410e-01 -7.4846426926387233e-01];
R3(3,:) = [2.8698466908561492e-02 -7.5301812454631367e-01 -6.5737363964632056e-01];
t3 = [-6.0451734755080713e-02; -3.9533167111966377e-01; 2.2979640654841407e+00];
t3 = -inv(R3)*t3;

% camera 3 orientation
i3 = R3(1,:);
j3 = R3(2,:);
k3 = R3(3,:);

NUM_CAMERAS = 3;
NUM_SCENES = 10;

% Read data from csv
Filelist = readtable("FileList.csv", 'ReadVariableNames', false);

for scene = 1 : NUM_SCENES
    disp(strcat('processing scene', num2str(scene)));
    
    % find start and end of the frames
    
    startframe = 0;
    endframe = 300;
    
    for cam = 1 : NUM_CAMERAS
        fname = Filelist{scene, cam}{1};
        baseName = fname(1:find(fname=='.')-1);
        annotationFile = strcat(baseName, '.csv');
        annotationFile = strcat('Annotation/', annotationFile);
        T = readtable(annotationFile);
        totalrows = height(T);
        
        % count largest start frame
        for r = 1 : totalrows
            if T.x(r) > 0
                frame = T.frame(r);
                if frame > startframe
                    startframe = frame;
                end
                break;
            end
        end
        
        % count smallest end frame
        for r = startframe + 1 : totalrows 
            if isnan(T.x(r))
                frame = T.frame(r);
                if frame - 1 < endframe
                    endframe= frame - 1;
                end
                break;
            end
        end
    end
    
    F = NUM_CAMERAS;
    N = endframe - startframe + 1;
    w = zeros(2*F, N);
    
    % For each frame in the video, construcut the w matrix (2F * N) from 3
    % camera views
    
    for cam = 1 : NUM_CAMERAS
        
        fname = Filelist{scene, cam}{1};
        baseName = fname(1:find(fname=='.')-1);
        annotationFile = strcat(baseName, '.csv');
        T = readtable(annotationFile);
        
        
        for curFrame = startframe : endframe
            undistortX = T.undistort_x(curFrame + 1);
            undistortY = T.undistort_y(curFrame + 1);
            
            if iscell(undistortY)
                undistortY = str2double(undistortY{1});
            end
            
            w(cam, curFrame - startframe + 1) = undistortX;
            w(cam + NUM_CAMERAS, curFrame - startframe + 1) = undistortY;
        end
        
    end
    
    % take the average horizontally
    w_avg = mean(w,2);
    for r = 1 : 2*F
        w(r,:) = w(r,:) - w_avg(r,1);
    end
    
    % using SVD:
    [Uw, Sw, Vw] = svd(w);
    S_p = Sw(1:3,1:3); % S is 3x3 sub-matrix of S
    U_p = Uw(:,1:3); % the first three columns of U 
    V_p = Vw(:,1:3); % the first three columns of V
    
    M_hat = U_p * sqrtm(S_p);
    S_hat = sqrtm(S_p) * transpose(V_p);
    
    
    % find a matrix A (3X3) that will give a geometrically correct (i.e.
    % Euclidean) solution
    
    If = M_hat(1 : F, :);
    Jf = M_hat(F + 1 : end, :);
    
    linearFunc = @(a, b)[a(1)*b(1), a(1)*b(2)+a(2)*b(1), a(1)*b(3)+a(3)*b(1), ...
              a(2)*b(2), a(2)*b(3)+a(3)*b(2), a(3)*b(3)];
    G = zeros(3 * F, 6);
    
    for f = 1 : 3 * F
        if f <= F
            G(f, :) = linearFunc(If(f, :), If(f, :));
        elseif f <= 2 * F
            curIdx = f - F;
            G(f, :) = linearFunc(Jf(curIdx, :), Jf(curIdx, :));
        else
            curIdx = f - 2 * F;
            G(f, :) = linearFunc(If(curIdx, :), Jf(curIdx,:));
        end
    end
    
    % solve Q for GQ = c
    c = [ones(2 * F, 1); zeros(F, 1)];
    Q = linsolve(G, c);
    Q = [Q(1) Q(2) Q(3);...
         Q(2) Q(4) Q(5);...
         Q(3) Q(5) Q(6)];
    
    % solve A for Q = AA^T
    [U, S, V] = svd(Q);
    x = sqrtm(S);
    A = U * x;
    
    num_frame = endframe - startframe + 1;
    frame_num = [startframe : endframe]';
    x = zeros(num_frame, 1);
    y = zeros(num_frame, 1);
    z = zeros(num_frame, 1);
    
    for curFrame = startframe : endframe
        curIdx = curFrame - startframe + 1;
        point = A \ S_hat(:, curIdx);
        x(curIdx) = point(1);
        y(curIdx) = point(2);
        z(curIdx) = point(3);
    end
    
    T = table(frame_num, x, y, z);
    
    folderName = 'Results';
    
    if ~exist(folderName, 'dir')
        mkdir(folderName);
    end
    
    resultName = strcat(folderName, '/scene', num2str(scene), '.csv');
    f = fopen(resultName, 'w');
    fclose(f);
    writetable(T, resultName);
end 















