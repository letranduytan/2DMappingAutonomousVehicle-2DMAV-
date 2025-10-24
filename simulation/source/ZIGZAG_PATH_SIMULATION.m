%% TWO WHEEL ROBOT - ZIGZAG PATH SIMULATION
clear; clc; close all;

% --- Robot parameters ---
L = 0.15;      % Distance between wheels (m)
dt = 0.05;     % Time step (s)
T = 20;        % Total simulation time (s)

% --- Initial state ---
x = 0; y = 0; theta = 0;

% --- Wheel velocities (zig-zag motion) ---
t = 0:dt:T;
vL = 0.12 + 0.04 * sin(0.5 * t);   % Left wheel velocity (m/s)
vR = 0.12 + 0.04 * cos(0.5 * t);   % Right wheel velocity (m/s)

% --- Storage for results ---
X = zeros(size(t));
Y = zeros(size(t));
TH = zeros(size(t));

% --- Simulation loop ---
for k = 1:length(t)
    v = (vR(k) + vL(k)) / 2;       % Linear velocity
    omega = (vR(k) - vL(k)) / L;   % Angular velocity
    
    % Update state
    x = x + v * cos(theta) * dt;
    y = y + v * sin(theta) * dt;
    theta = theta + omega * dt;
    
    X(k) = x;
    Y(k) = y;
    TH(k) = theta;
end

% --- Plot Zig-Zag Path ---
figure('Name', 'Zig-Zag Path of Robot', 'NumberTitle', 'off');
plot(X, Y, 'b-', 'LineWidth', 2); hold on;
quiver(X(1:20:end), Y(1:20:end), cos(TH(1:20:end)), sin(TH(1:20:end)), 0.2, 'r');
title('Zig-Zag Path of Differential Drive Robot');
xlabel('X Position (m)');
ylabel('Y Position (m)');
axis equal; grid on;

% --- Plot Yaw Angle over Time ---
figure('Name', 'Yaw Angle vs Time', 'NumberTitle', 'off');
plot(t, rad2deg(unwrap(TH)), 'm', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Yaw Angle (deg)');
title('Yaw Angle over Time (Zig-Zag Motion)');
grid on;
