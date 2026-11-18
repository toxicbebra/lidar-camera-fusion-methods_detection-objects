clear all; 
close all; 
clc;

% Загрузка записанных датасетов
im_data = load('camera_Gendataset_1.mat');
pc_data = load('lidar_Gendataset_1.mat');
images = im_data.vout;
pointClouds = pc_data.lidar_dataset;

% Создание объекта внутренних параметров камеры 
focalLength = [1109, 1109];
principalPoint = [640, 360];
imageSize = [720, 1280];

intrinsics = cameraIntrinsics(focalLength, principalPoint, imageSize, ...
    'RadialDistortion', [0 0], ...
    'TangentialDistortion', [0 0], ...
    'Skew', 0);

% Матрица поворота для калибровки систем координат камеры и лидара
R = [ 0, -1,  0; 
      0,  0, -1; 
      1,  0,  0 ];

tform = rigid3d(R, [0 0 0]);

% Обработка изображений и облака точек 
processed_images = cameraProcess(images);
processed_clouds = LidarProcess(pointClouds);

% Выбор конкретного кадра для анализа
frame_idx = 101;
img = processed_images(:, :, :, frame_idx);
ptCloud = processed_clouds{frame_idx};

% Комплексирование методом раннего слияния
ptCloudFused = fuseCameraToLidar(img, ptCloud, intrinsics, tform);

% Детекция разметки по цвету с использованием пространства HSV
hsv_colors = rgb2hsv(double(ptCloudFused.Color) / 255);

% Условия для белого цвета: низкая насыщенность и высокая яркость
white_mask = (hsv_colors(:,2) < 0.2) & (hsv_colors(:,3) > 0.6);
marking_points = ptCloudFused.Location(white_mask, :);

% Визуализация результатов
figure;
subplot(1,3,1);
pcshow(ptCloudFused);
title('Исходное цветное облако');

subplot(1,3,2);
pcshow(marking_points);
title('Детектированная разметка');