% ============================================================
% MAZE EXPLORER with LIDAR (DFS + No Immediate Backward)
% - 4 directions (up, down, left, right)
% - Revisiting old cells is allowed
% - No diagonal moves
% - Cannot move backward immediately (must turn 180° first)
% - LIDAR scans 180° and displays detected points (right side)
% ============================================================
% Author: Le Tran Duy Tan

clear; close all; clc;

pauseTime = 0.03;

% --- Hidden Maze ---
trueMaze = [ ...
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;
1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 1;
1 0 1 1 0 1 0 1 1 0 1 0 1 1 0 1 0 1 0 1;
1 0 0 0 0 0 0 1 0 0 0 0 1 0 0 1 0 1 0 1;
1 1 1 1 1 1 0 1 1 1 1 0 1 0 1 1 0 1 0 1;
1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 1;
1 0 1 1 0 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1;
1 0 0 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0 1;
1 0 1 1 1 1 0 1 1 1 1 0 1 0 1 1 1 1 0 1;
1 0 0 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0 1;
1 1 1 1 1 1 0 1 1 1 1 0 1 0 1 1 0 1 0 1;
1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 1;
1 0 1 1 0 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1;
1 0 0 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0 1;
1 0 1 1 1 1 0 1 1 1 1 0 1 0 1 1 1 1 0 1;
1 0 0 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0 1;
1 1 1 1 1 1 0 1 1 1 1 0 1 0 1 1 0 1 0 1;
1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 1;
1 0 1 1 0 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1;
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];

[m,n] = size(trueMaze);
mazeKnown = nan(m,n);
mazeKnown(1,:)=1; mazeKnown(end,:)=1;
mazeKnown(:,1)=1; mazeKnown(:,end)=1;

dirs = [0 1; 1 0; 0 -1; -1 0]; % right, down, left, up
start = [2,2];
visited = zeros(m,n);
stack = [start 0]; % [r c dir]
path = start;

% --- Store LIDAR points ---
lidarPoints = [];

%%%%%% Visualization setup %%%%%%
figure('Name','DFS Maze Explorer','Color','w');
colormap([1 1 0; 0 0 1; 0.9 0.9 0.9]);
set(gcf,'Position',[100 100 1200 600]);

%%%%%% DFS Exploration %%%%%%
while ~isempty(stack)
pos = stack(end,1:2);
dir = stack(end,3);
r=pos(1); c=pos(2);

% --- LIDAR scan ---
theta = dir*pi/2;
lidarAngles = linspace(-pi/2, pi/2, 9) + theta;
hits = [];
for a = lidarAngles
    for d = 0:0.2:4
        xr = c + d*cos(a);
        yr = r + d*sin(a);
        mi = round(yr); mj = round(xr);
        if mi<1||mj<1||mi>m||mj>n, break; end
        if trueMaze(mi,mj)==1
            mazeKnown(mi,mj)=1;
            hits = [hits; xr yr];
            break;
        else
            mazeKnown(mi,mj)=0;
        end
    end
end
lidarPoints = [lidarPoints; hits]; % store all scanned points

% --- Subplot 1: Maze view ---
subplot(1,2,1);
cla; imagesc(mazeKnown,'AlphaData',~isnan(mazeKnown));
axis equal tight; hold on;
title('DFS Robot Exploration (No Backward, No Diagonal)');
xlabel('Column'); ylabel('Row'); set(gca,'YDir','normal');
xlim([0 25]); ylim([0 25]);
plot(path(:,2), path(:,1), 'r-', 'LineWidth', 2);
tri=[0.4 0; -0.3 -0.2; -0.3 0.2];
R=[cos(theta) -sin(theta); sin(theta) cos(theta)];
triPos=(R*tri')'+[c r];
fill(triPos(:,1), triPos(:,2),'r','EdgeColor','k');
plot(c+0.5*cos(theta), r+0.5*sin(theta), 'go','MarkerFaceColor','g');
for a=lidarAngles
    plot([c c+3*cos(a)], [r r+3*sin(a)],'r--');
end

% --- Subplot 2: LIDAR point cloud ---
subplot(1,2,2);
cla; hold on; grid on; axis equal;
title('LIDAR Point Cloud');
xlabel('X (columns)'); ylabel('Y (rows)');
plot(lidarPoints(:,1), lidarPoints(:,2), 'r.', 'MarkerSize', 10);
plot(c, r, 'go', 'MarkerFaceColor','g');
xlim([0 25]); ylim([0 25]);

drawnow; pause(pauseTime);

visited(r,c)=1;
moved=false;

% --- Try moving in available directions ---
for turn=[0 1 -1 2]  % Priority: forward, right, left, then 180° turn
    ndir = mod(dir + turn, 4);
    np = pos + dirs(ndir+1,:);
    if trueMaze(np(1),np(2))==0 && visited(np(1),np(2))==0
        if turn == 2
            theta = theta + pi; % rotate only
            drawnow; pause(pauseTime);
            continue;
        end
        path=[path; np];
        stack=[stack; np ndir];
        moved=true;
        break;
    end
end

if ~moved
    theta = theta + pi;
    stack(end,:) = [];
    if size(stack,1)>0
        path = [path; stack(end,1:2)];
    end
end


end

disp('✅ Exploration complete with LIDAR point cloud display (25x25 view)!');