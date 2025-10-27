% ================================================================
%   ROBOT DYNAMICS SIMULATION — DIFFERENTIAL DRIVE MODEL
%   Including DC Motor and Kinematic Model
%   Author: Le Tran Duy Tan
%   Date: 2025-10-28
% ================================================================

clear all;
clc;

% ==================== MOTOR AND ROBOT PARAMETERS ====================
R = 1.0;               % Motor resistance (Ohm)
L = 0.5e-3;            % Motor inductance (H)
Kt = 0.01;             % Motor torque constant (Nm/A)
Kb = 0.01;             % Back EMF constant (V/(rad/s))
Jm = 1e-4;             % Motor inertia (kg*m^2)
Bm = 1e-4;             % Motor viscous friction (N*m*s/rad)

r = 0.05;              % Wheel radius (m)
Lr = 0.2;              % Distance between two wheels (m)
Jr = 0.01;             % Robot body inertia (kg*m^2)
Br = 0.01;             % Robot friction coefficient (N*m*s/rad)

% ==================== INITIAL CONDITIONS ====================
tspan = [0 10];
x0 = [0; 0; 0; 0; 0];  % [IL; IR; omegaL; omegaR; theta]

% ==================== INPUT VOLTAGE (LEFT & RIGHT) ====================
VL = @(t) 12 * (t < 5) + 6 * (t >= 5);   % Left motor voltage (V)
VR = @(t) 12 * (t < 5) + 6 * (t >= 5);   % Right motor voltage (V)

% ==================== ODE FUNCTION ====================
f = @(t, x) robot_dynamics(t, x, VL, VR, R, L, Kt, Kb, Jm, Bm, r, Lr, Jr, Br);

% ==================== SOLVE SYSTEM ====================
[t, x] = ode45(f, tspan, x0);

% ==================== PLOT RESULTS ====================
figure('Name', 'Differential Drive Robot Simulation', 'Color', 'w');

subplot(3,1,1);
plot(t, x(:,1), 'r', t, x(:,2), 'b', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Current (A)');
legend('I_L', 'I_R');
title('Motor Currents');

subplot(3,1,2);
plot(t, x(:,3), 'r', t, x(:,4), 'b', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Angular Speed (rad/s)');
legend('ω_L', 'ω_R');
title('Wheel Angular Velocities');

subplot(3,1,3);
plot(t, x(:,5), 'k', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Orientation (rad)');
title('Robot Orientation θ');

disp('✅ Simulation complete — Differential drive dynamics successfully modeled.');

% ================================================================
%   FUNCTION: robot_dynamics
% ================================================================
function dx = robot_dynamics(t, x, VL, VR, R, L, Kt, Kb, Jm, Bm, r, Lr, Jr, Br)
    IL = x(1); IR = x(2);
    wL = x(3); wR = x(4);
    theta = x(5);

    % Electrical dynamics
    dIL = (VL(t) - R*IL - Kb*wL) / L;
    dIR = (VR(t) - R*IR - Kb*wR) / L;

    % Motor torques
    TL = Kt * IL;
    TR = Kt * IR;

    % Mechanical dynamics
    dwL = (TL - Bm*wL - (r/Lr)*(TL - TR)) / Jm;
    dwR = (TR - Bm*wR + (r/Lr)*(TL - TR)) / Jm;

    % Robot body rotation (orientation)
    dtheta = (r / (2*Lr)) * (wR - wL);

    dx = [dIL; dIR; dwL; dwR; dtheta];
end
