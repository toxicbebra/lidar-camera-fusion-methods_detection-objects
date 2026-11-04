%% Создание сценария с самолётом из .obj-модели
clear; clc;

%% 1. Параметры
objFileName = 'my_airplane.obj';
length = 8.28;
width  = 11.0;
height = 2.72;
startPos = [0, 0, 0];
speed    = 30;

%% 2. Чтение .obj
[vertices, faces] = readObjFile(objFileName);

%% 3. Меш
mesh = extendedObjectMesh(vertices, faces);

%% 4. Сценарий и самолёт
scenario = drivingScenario('SampleTime', 0.1);
airplane = actor(scenario, ...
    'ClassID', 4, ...
    'Mesh', mesh, ...
    'Length', length, ...
    'Width',  width, ...
    'Height', height, ...
    'Position', startPos, ...
    'Yaw', 0);

%% 5. Траектория — ДО открытия приложения!
waypoints = [startPos; startPos + [200, 0, 0]];
trajectory(airplane, waypoints, speed);

%% 6. Диагностика — ДО открытия приложения
fprintf('Сценарий создан.\n');
fprintf('  Модель: %s\n', objFileName);
fprintf('  Габариты: %.1f × %.1f × %.1f м\n', length, width, height);
fprintf('  Стартовая позиция: [%.1f, %.1f, %.1f]\n', startPos);
fprintf('  Скорость: %.1f м/с\n', speed);
disp('Открываю Driving Scenario Designer (скрипт ждёт закрытия окна)...');

%% 7. Открываем приложение ОДИН раз (блокирует до закрытия)
drivingScenarioDesigner(scenario);

disp('Приложение закрыто, скрипт завершён.');

%% ===== Вспомогательная функция (в самом конце файла) =====
function [V, F] = readObjFile(filename)
    fid = fopen(filename, 'r');
    if fid == -1
        error('Не удалось открыть файл: %s', filename);
    end
    V = [];
    F = [];
    while ~feof(fid)
        line = strtrim(fgetl(fid));
        if isempty(line) || line(1) == '#'
            continue;
        end
        parts = strsplit(line, ' ');
        switch parts{1}
            case 'v'
                V(end+1, :) = str2double(parts(2:4));
            case 'f'
                faceIdx = zeros(1, numel(parts)-1);
                for i = 2:numel(parts)
                    vertexStr = strsplit(parts{i}, '/');
                    faceIdx(i-1) = str2double(vertexStr{1});
                end
                if any(faceIdx < 0)
                    faceIdx = size(V, 1) + faceIdx + 1;
                end
                if numel(faceIdx) == 3
                    F(end+1, :) = faceIdx;
                elseif numel(faceIdx) > 3
                    for k = 2:numel(faceIdx)-1
                        F(end+1, :) = [faceIdx(1), faceIdx(k), faceIdx(k+1)];
                    end
                end
        end
    end
    fclose(fid);
end