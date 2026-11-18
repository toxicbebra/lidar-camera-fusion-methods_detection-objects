function [Processed_PCloud] = LidarProcess(PointCloud)

num_frames = size(PointCloud, 4);
Processed_PCloud = cell(num_frames, 1);    


for i = 1:num_frames
    % 1. Извлекаем сырой кадр
    raw_frame = PointCloud(:, :, :, i);
    
    % 2. Преобразуем в список точек (Nx3) и создаем объект pointCloud
    points_list = reshape(raw_frame, [], 3);
    ptCloud = pointCloud(points_list);
    
    % 3. Обрабатываем (удаляем NaN)

    Processed_PCloud{i} = removeInvalidPoints(ptCloud);
    
    % Прогресс
    if mod(i, 50) == 0
        fprintf('Обработано облаков: %d из %d\n', i, num_frames);
    end
end

