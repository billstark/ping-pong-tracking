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

A = [i1; j1; i2; j2; i3; j3];
i_f = [i1; i2; i3];
j_f = [j1; j2; j3];
t_f = [t1; t2; t3];

% Read data from csv
Filelist = readtable("FileList.csv", 'ReadVariableNames', false);

for scene = 1 : 10
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
    
    num_frame = endframe - startframe + 1;
    x = zeros(num_frame, 1);
    y = zeros(num_frame, 1);
    z = zeros(num_frame, 1);
    
    for curFrame = startframe : endframe
        c = zeros(6, 1);
        
        for cam = 1: NUM_CAMERAS
            fname = Filelist{scene, cam}{1};
            baseName = fname(1:find(fname=='.')-1);
            annotationFile = strcat(baseName, '.csv');
            annotationFile = strcat('Annotation/', annotationFile);
            T = readtable(annotationFile);
            
            undistortX = T.undistort_x(curFrame + 1);
            undistortY = T.undistort_y(curFrame + 1);
            
            if iscell(undistortY)
                undistortY = str2double(undistortY{1});
            end
            
            c(cam*2 - 1) = undistortX + t_f(cam)*i_f(cam);
            c(cam*2) = undistortY + t_f(cam)*j_f(cam);
        end
        
        scenePoint = linsolve(A, c);
        curIdx = curFrame - startframe + 1;
        x(curIdx) = scenePoint(1);
        y(curIdx) = scenePoint(2);
        z(curIdx) = scenePoint(3);
    end
    
%     x(num_frame + 1) = t1(1);
%     x(num_frame + 2) = t2(1);
%     x(num_frame + 3) = t3(1);
%     y(num_frame + 1) = t1(2);
%     y(num_frame + 2) = t2(2);
%     y(num_frame + 3) = t3(2);
%     z(num_frame + 1) = t1(3);
%     z(num_frame + 2) = t2(3);
%     z(num_frame + 3) = t3(3);
    
    T = table(x, y, z);
    
    folderName = 'Results';
    
    if ~exist(folderName, 'dir')
        mkdir(folderName);
    end
    
    resultName = strcat(folderName, '/scene', num2str(scene), '.csv');
    f = fopen(resultName, 'w');
    fclose(f);
    writetable(T, resultName,'WriteVariableNames',false,'WriteRowNames',false);
end