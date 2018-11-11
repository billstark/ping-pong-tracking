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

% Read data from csv
sceneNum = 10; % total number of video scenes
Filelist = readtable("FileList.csv", 'ReadVariableNames', false);

% ======================================================
% TODO: 
% ======================================================
addpath('C:\Users\Ruolan\Documents\MATLAB\Annotation');

for scene = 3:3 % replaced by starsceneNum later
    % find start and end of the frames
    startframe = 0;
    endframe = 300; 
    for cam = 1:3
        fname = Filelist{scene, cam}{1};
        baseName = fname(1:find(fname=='.')-1);
        annotaionFile = strcat(baseName, '.csv');
        T = readtable(annotaionFile);
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
                if frame < endframe
                    endframe= frame - 1; 
                end
                break;
            end
        end
    end
    % Total number of frames: F
    F = endframe - startframe + 1;
    % Total number of 3D points: N
    N = 3;
    
    % form the 2F*N matrix w
    w = zeros(2*F, N);
    
    % read all frames 
    for cam = 1:3
        fname = Filelist{scene, cam}{1};
        baseName = fname(1:find(fname=='.')-1);
        annotaionFile = strcat(baseName, '.csv');
        T = readtable(annotaionFile);
        for r = startframe + 1 : endframe + 1
            % problem: undistort_y data type is array
            x = T.undistort_x(r);
            y_a = T.undistort_y(r);
            if iscell(y_a)
                y = str2double(y_a{1});
            else
                y = y_a;
            end
            % store the 2d coords into matrx w [DONE]
            w(T.frame(r)- startframe + 1, cam) = x;
            w(F + T.frame(r)- startframe + 1, cam) = y;   
        end    
    end
    
    % take the average horizontally
    w_avg = mean(w,2);
    w_subavg = zeros(2*F,N);
    for r = 1:2*F
        w_subavg(r,:) = w(r,:) - w_avg(r,1); 
    end
    
    % using SVD:
    [Uw, Sw, Vw] = svd(w_subavg);
    S_p = Sw(1:3,1:3); % S' is 3x3 sub-matrix of S
    U_p = Uw(:,1:3); % the first three columns of U 
    V_p = Vw(:,1:3); % the first three columns of V
    
    M = U_p * sqrtm(S_p);
    S = sqrtm(S_p) * transpose(V_p);
    
    % find a matrix A (3X3) that will give a geometrically correct (i.e.
    % Euclidean) solution
    
    
    
end 















