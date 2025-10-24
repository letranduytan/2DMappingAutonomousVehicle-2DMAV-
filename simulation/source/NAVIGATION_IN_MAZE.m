%% ROBOT NAVIGATION IN MAZE WITH OBSTACLE AVOIDANCE
clear; clc; close all;

% --- Parameters ---
maze = [ ...
    1 1 1 1 1 1 1 1 1 1;
    1 0 0 0 1 0 0 0 0 1;
    1 0 1 0 1 0 1 1 0 1;
    1 0 1 0 0 0 0 1 0 1;
    1 0 1 1 1 1 0 1 0 1;
    1 0 0 0 0 0 0 1 0 1;
    1 1 1 1 1 1 0 1 0 1;
    1 0 0 0 0 0 0 0 0 1;
    1 0 1 1 1 1 1 1 0 1;
    1 1 1 1 1 1 1 1 1 1];  % Maze map

[m, n] = size(maze);
cell_size = 1;   % 1 unit per grid
dt = 0.1;        % Time step
steps = 800;     % Simulation steps

% --- Robot initial state ---
x = 2; y = 2; theta = 0;  % Start at (2,2), facing right
path = [x, y];

% --- Plot setup ---
figure('Name','Maze Navigation Robot','NumberTitle','off');
hold on; axis equal;
imagesc(flipud(maze)); colormap(gray);
set(gca, 'YDir','normal');
title('Robot Navigation in Maze (Avoid Obstacles)');
xlabel('X'); ylabel('Y');
grid on;

% --- Simulation loop ---
for k = 1:steps
    % --- Compute next cell in front ---
    x_next = x + cos(theta);
    y_next = y + sin(theta);
    cell_x = round(x_next);
    cell_y = round(y_next);
    
    % --- Check collision with wall ---
    if maze(m - cell_y + 1, cell_x) == 1
        % Wall detected → turn left or right 90 degrees
        if rand() > 0.5
            theta = theta + pi/2;  % turn left
        else
            theta = theta - pi/2;  % turn right
        end
    else
        % Move forward
        x = x_next;
        y = y_next;
    end
    
    % --- Store path ---
    path = [path; x, y];
    
    % --- Draw robot ---
    if mod(k, 5) == 0
        plot(path(:,1), path(:,2), 'b-', 'LineWidth', 1.5);
        plot(x, y, 'ro', 'MarkerFaceColor', 'r');
        pause(0.01);
    end
end

% --- Final path ---
plot(path(:,1), path(:,2), 'b-', 'LineWidth', 2);
disp('Simulation complete.');
