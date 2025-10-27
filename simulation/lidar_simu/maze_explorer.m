% ============================================================
%  MAZE EXPLORER (REVISIT VERSION)
%  Robot explores all yellow cells (4-directional moves only)
%  It can revisit old cells but never moves diagonally or into blue walls
% ============================================================

clear; close all; clc;

%%%%%% Parameters %%%%%%
gridSize = [15, 21];
pauseTime = 0.03;

% --- Maze creation ---
maze = zeros(gridSize); % 0 = yellow (free), 1 = blue (wall)
maze(1,:) = 1; maze(end,:) = 1; maze(:,1) = 1; maze(:,end) = 1;
maze(4,3:12)=1; maze(8,6:18)=1; maze(11,4:10)=1; maze(6:10,14)=1;

% random walls
rng(1);
for k=1:25
    r=randi([2,gridSize(1)-1]); c=randi([2,gridSize(2)-1]);
    maze(r,c)=1;
end

start_pos = [2,2];
if maze(start_pos(1),start_pos(2))==1
    error('⚠️ Start cell is inside a wall!');
end

% --- 4 directions (no diagonal) ---
dirs = [0 1; 1 0; 0 -1; -1 0];  % [right; down; left; up]

visited = zeros(size(maze));
visited(start_pos(1), start_pos(2)) = 1;

path = start_pos;
stack = start_pos;

freeCells = sum(maze(:)==0);

%%%%%% Visualization setup %%%%%%
figure('Name','Maze Explorer (No Diagonal, Can Revisit)','Color','w');
colormap([1 1 0; 0 0 1]); % yellow=free, blue=wall
imagesc(maze); set(gca,'YDir','normal');
axis equal tight; hold on;
title('Robot exploring all yellow cells (4-directional, can revisit)');
xlabel('Column'); ylabel('Row');

hrobot = plot(start_pos(2), start_pos(1), 'o', ...
    'MarkerSize',10, 'MarkerFaceColor','g', 'MarkerEdgeColor','k');
drawnow;

%%%%%% Exploration (Depth-First Search with Revisit) %%%%%%
while ~isempty(stack)
    pos = stack(end,:);
    r = pos(1); c = pos(2);

    % find next possible moves (up, down, left, right)
    moves = [];
    for i = 1:4
        nr = r + dirs(i,1);
        nc = c + dirs(i,2);
        if nr>=1 && nr<=gridSize(1) && nc>=1 && nc<=gridSize(2)
            if maze(nr,nc)==0 % yellow only
                moves = [moves; nr nc];
            end
        end
    end

    % choose next move
    moved = false;
    for i = 1:size(moves,1)
        nr = moves(i,1); nc = moves(i,2);
        if visited(nr,nc)==0
            % move to unvisited yellow
            visited(nr,nc)=1;
            path = [path; nr nc];
            stack = [stack; nr nc];
            moved = true;
            break;
        end
    end

    % if all neighbors visited → backtrack (allowed)
    if ~moved
        stack(end,:) = [];
        if ~isempty(stack)
            path = [path; stack(end,:)]; % go back visually
        end
    end

    % draw robot & path
    if size(path,1)>1
        p1 = path(end-1,:);
        p2 = path(end,:);
        line([p1(2) p2(2)], [p1(1) p2(1)], 'Color','r', 'LineWidth',2);
    end
    set(hrobot,'XData',path(end,2),'YData',path(end,1));
    drawnow;
    pause(pauseTime);

    if sum(visited(:)) == freeCells
        disp('✅ All yellow cells explored!');
        break;
    end
end

disp('Simulation complete.');
fprintf('Visited %d / %d yellow cells.\n', sum(visited(:)), freeCells);

%%%%%% Final plot %%%%%%
figure('Name','Final Map (Revisit OK, No Diagonal)','Color','w');
imagesc(maze); set(gca,'YDir','normal');
colormap([1 1 0; 0 0 1]); axis equal tight; hold on;
for k = 2:size(path,1)
    p1 = path(k-1,:); p2 = path(k,:);
    if all(maze(p1(1),p1(2))==0) && all(maze(p2(1),p2(2))==0)
        line([p1(2) p2(2)], [p1(1) p2(1)], 'Color','r', 'LineWidth',2);
    end
end
plot(start_pos(2),start_pos(1),'go','MarkerFaceColor','g','MarkerSize',10);
plot(path(end,2),path(end,1),'ro','MarkerFaceColor','r','MarkerSize',10);
title('Final Coverage Path (Revisit Allowed, 4-way)');
legend('Walls (Blue)','Path','Start','End','Location','bestoutside');
