%% TWO WHEEL ROBOT - ROTATION IN PLACE
clear; clc; close all;

% --- Robot parameters ---
L = 0.15;      % Distance between wheels (m)
dt = 0.1;      % Time step (s)
T = 10;        % Simulation duration (s)

% --- Initial state ---
x = 0; y = 0; theta = 0;

% --- Wheel velocities (rotate in place) ---
t = 0:dt:T;
vL = -0.05 * ones(size(t));   % Left wheel backward
vR =  0.05 * ones(size(t));   % Right wheel forward

% --- Storage ---
X = zeros(size(t)); 
Y = zeros(size(t)); 
TH = zeros(size(t));

% --- Simulation loop ---
for k = 1:length(t)
    v = (vR(k) + vL(k)) / 2;       % Linear velocity (≈ 0)
    omega = (vR(k) - vL(k)) / L;   % Angular velocity (rad/s)
    
    % Update position (x, y almost constant)
    x = x + v * cos(theta) * dt;
    y = y + v * sin(theta) * dt;
    theta = theta + omega * dt;    % Update heading
    
    X(k) = x; 
    Y(k) = y; 
    TH(k) = theta;
end

% --- Plot path ---
figure('Name', 'Rotation in Place', 'NumberTitle', 'off');
plot(X, Y, 'b-', 'LineWidth', 2);
hold on;
quiver(X(1:10:end), Y(1:10:end), cos(TH(1:10:end)), sin(TH(1:10:end)), 0.2, 'r');
title('Robot Rotating in Place');
xlabel('X Position (m)');
ylabel('Y Position (m)');
axis equal; grid on;

% --- Plot yaw angle ---
figure('Name','Yaw Angle vs Time','NumberTitle','off');
plot(t, rad2deg(unwrap(TH)), 'r', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Yaw Angle (deg)');
title('Yaw Angle over Time (Rotation in Place)');
grid on;
