imagePath = fullfile(toolboxdir('lidar'),'lidardata','lcc','HDL64','images');
ptCloudPath = fullfile(toolboxdir('lidar'),'lidardata','lcc','HDL64','pointCloud');
cameraParamsPath = fullfile(imagePath,'calibration.mat');

% Load camera intrinsics.
intrinsic = load(cameraParamsPath);

% Load images using imageDatastore.
imds = imageDatastore(imagePath);
imageFileNames = imds.Files;

% Load point cloud files.
pcds = fileDatastore(ptCloudPath,'ReadFcn',@pcread);
ptCloudFileNames = pcds.Files;

% Square size of the checkerboard.
squareSize = 200;

% Set random seed to generate reproducible results.
rng('default')

[imageCorners3d,checkerboardDimension,dataUsed] = ...
    estimateCheckerboardCorners3d(imageFileNames,intrinsic.cameraParams,squareSize);

% Remove image files that are not used.
imageFileNames = imageFileNames(dataUsed);


% Filter the point cloud files that are not used for detection.
ptCloudFileNames = ptCloudFileNames(dataUsed);
[lidarCheckerboardPlanes,framesUsed,indices] = ...
    detectRectangularPlanePoints(ptCloudFileNames,checkerboardDimension,ROI=roi);

% Remove ptCloud files that are not used.
ptCloudFileNames = ptCloudFileNames(framesUsed);

% Remove image files.
imageFileNames = imageFileNames(framesUsed);

% Remove 3-D corners from images.
imageCorners3d = imageCorners3d(:,:,framesUsed);

[tform,errors] = estimateLidarCameraTransform(lidarCheckerboardPlanes, ...
    imageCorners3d,intrinsic.cameraParams);

%% Сгенерированные данные с датчиков

scenario = drivingScenario;

ptCloud = truck_data(1).PointClouds{1};   % фигурные скобки — потому что cell
ptCloud                                    % выведет описание объекта
ptCloud.Count                              % сколько точек
ptCloud.Location                           % матрица N×3 с координатами

% Соберём счётчики точек по всем кадрам
counts = zeros(147, 1);
for k = 1:147
    pc = truck_data(k).PointClouds{1};
    counts(k) = pc.Count;
end

figure; plot(counts, '-o'); grid on;
xlabel('Кадр'); ylabel('Число точек');
title('Плотность облака по кадрам');