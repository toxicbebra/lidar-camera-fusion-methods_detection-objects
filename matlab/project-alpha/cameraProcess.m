function [images] = cameraProcess(images_data)
    % 1. Узнаем размеры датасета
    [height, width, channels, num_frames] = size(images_data);
    
    % 2. Создаем пустой массив для обработанных кадров (RGB, 3 канала)
    images = zeros(height, width, 3, num_frames, 'uint8'); 
    
    % 3. Проходимся циклом по каждому кадру
    for i = 1:num_frames
        % Извлекаем один кадр
        current_frame = images_data(:, :, :, i);
        
        % Подавление шумов
        current_frame = imgaussfilt(current_frame, 1);
        
        % Нормализация яркости
        processed_frame = imadjust(current_frame, stretchlim(current_frame), []);
    
        % Записываем результат в большой массив
        images(:, :, :, i) = uint8(processed_frame);
        
        % Выводим прогресс в консоль (каждые 50 кадров)
        if mod(i, 50) == 0
            fprintf('Обработано кадров: %d из %d\n', i, num_frames);
        end
    end
end