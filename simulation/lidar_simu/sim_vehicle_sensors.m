clear; close all; clc;

%% --- Parameters ---
R = 0.03;   % Wheel radius (m)
B = 0.18;   % Distance between wheels (m)
dt = 0.01;  % Time step (s)
v_forward = 0.1;     % Forward speed (m/s)
omega_turn = pi/4;   % Angular velocity when turning (rad/s)

%% --- Motion sequence (longer path) ---
% [duration, v, omega]
motion_seq = [ ...
    6, v_forward, 0;        % move straight
    2, 0, -omega_turn;      % turn right 90°
    6, v_forward, 0;        % move straight
    2, 0,  omega_turn;      % turn left 90°
    6, v_forward, 0;        % move straight
    2, 0, -omega_turn;      % turn right 90°
    6, v_forward, 0;        % move straight
    2, 0,  omega_turn;      % turn left 90°
    6, v_forward, 0];       % final straight segment

Tsim = sum(motion_seq(:,1));
N = floor(Tsim/dt);
time = (0:N-1)*dt;

v_cmd = zeros(N,1);
omega_cmd = zeros(N,1);
idx = 1;
for i = 1:size(motion_seq,1)
    dur = motion_seq(i,1);
    len = floor(dur/dt);
    v_cmd(idx:idx+len-1) = motion_seq(i,2);
    omega_cmd(idx:idx+len-1) = motion_seq(i,3);
    idx = idx+len;
end

%% --- Initialization ---
x = 0; y = 0; theta = 0;
veh_length = 0.25; veh_width = 0.14;
rect = [-veh_length/2, -veh_width/2;
         veh_length/2, -veh_width/2;
         veh_length/2,  veh_width/2;
        -veh_length/2,  veh_width/2];

%% --- Visualization ---
fig = figure('Name','Long Path Vehicle Simulation','Position',[100 100 800 700]);
ax = axes('Position',[0.08 0.08 0.85 0.85]);
axis(ax,[-3 10 -3 10]); axis equal; grid on; hold on;
title('Vehicle Long Path + Wheel State');

vehPatch = patch('XData',[],'YData',[],'FaceColor',[0 0.6 0.9],'EdgeColor','k');
traj = plot(ax,0,0,'g','LineWidth',1.2);
txt = text(-2.8,9.5,'','FontSize',11);

arrow_L = quiver(0,0,0,0,'r','LineWidth',1.5,'MaxHeadSize',2);
arrow_R = quiver(0,0,0,0,'r','LineWidth',1.5,'MaxHeadSize',2);

%% --- Simulation ---
X = zeros(N,3);
for k = 1:N
    v_des = v_cmd(k);
    omega_des = omega_cmd(k);

    % Wheel control
    if abs(omega_des) > 1e-3
        vR = v_forward * (1 + sign(omega_des)*0.5);
        vL = v_forward * (1 - sign(omega_des)*0.5);
    else
        vR = v_des; vL = v_des;
    end

    % Kinematic model
    v = (vR + vL)/2;
    omega = (vR - vL)/B;

    x = x + dt * v * cos(theta);
    y = y + dt * v * sin(theta);
    theta = theta + dt * omega;
    X(k,:) = [x y theta];

    % --- Visualization update ---
    if mod(k,5)==0
        Rm = [cos(theta) -sin(theta); sin(theta) cos(theta)];
        pts = (Rm * rect')';
        set(vehPatch,'XData',pts(:,1)+x,'YData',pts(:,2)+y);
        set(traj,'XData',X(1:k,1),'YData',X(1:k,2));

        pL = [x; y] + Rm*[-veh_length/2; -B/2];
        pR = [x; y] + Rm*[-veh_length/2;  B/2];

        dirL = Rm*[vL; 0]*1.5;
        dirR = Rm*[vR; 0]*1.5;
        set(arrow_L,'XData',pL(1),'YData',pL(2),'UData',dirL(1),'VData',dirL(2));
        set(arrow_R,'XData',pR(1),'YData',pR(2),'UData',dirR(1),'VData',dirR(2));

        if abs(vR - vL) < 1e-3
            state = 'Moving straight';
        elseif vR > vL
            state = 'Turning right';
        else
            state = 'Turning left';
        end

        set(txt,'String',sprintf(['t=%.1fs\nx=%.2f  y=%.2f  θ=%.0f°\n' ...
            'Left wheel: %.2f m/s\nRight wheel: %.2f m/s\nState: %s'], ...
            time(k),x,y,rad2deg(theta),vL,vR,state));

        drawnow limitrate;
        pause(0.01);
    end
end
