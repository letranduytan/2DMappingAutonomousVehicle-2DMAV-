%% TWO WHEEL ROBOT SIMULATION (2D)
% Author: Lê Trần Duy Tân
% Differential Drive Kinematics Simulation

clear; clc; close all;

% --- Robot parameters ---
L = 0.15;          % Distance between wheels (m)
dt = 0.1;          % Time step (s)
T = 20;            % Total simulation time (s)

% --- Initial conditions ---
x = 0;             % Initial X position (m)
y = 0;             % Initial Y position (m)
theta = 0;         % Initial heading (rad)

% --- Control inputs (wheel speeds) ---
% You can modify these for different trajectories
t = 0:dt:T;
vL = 0.10 + 0.05*sin(0.3*t);   % Left wheel velocity (m/s)
vR = 0.10 + 0.05*cos(0.3*t);   % Right wheel velocity (m/s)

% --- Storage for plotting ---
X = zeros(size(t));
Y = zeros(size(t));
TH = zeros(size(t));

% --- Simulation loop ---
for k = 1:length(t)
    v = (vR(k) + vL(k)) / 2;         % Linear velocity
    omega = (vR(k) - vL(k)) / L;     % Angular velocity
    
    % Update position
    x = x + v * cos(theta) * dt;
    y = y + v * sin(theta) * dt;
    theta = theta + omega * dt;
    
    % Store results
    X(k) = x;
    Y(k) = y;
    TH(k) = theta;
end

% --- Plot results ---
figure('Name', '2D Path of Differential Drive Robot', 'NumberTitle', 'off');
plot(X, Y, 'b-', 'LineWidth', 2);
hold on;
quiver(X(1:20:end), Y(1:20:end), cos(TH(1:20:end)), sin(TH(1:20:end)), 0.2, 'r');
title('Path of Differential Drive Robot');
xlabel('X Position (m)');
ylabel('Y Position (m)');
axis equal;
grid on;

% --- Plot heading over time ---
figure('Name','Yaw Angle vs Time','NumberTitle','off');
plot(t, rad2deg(unwrap(TH)), 'r', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Heading Angle (deg)');
title('Yaw Angle over Time');
grid on;
