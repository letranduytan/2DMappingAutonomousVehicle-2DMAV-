% ============================================================
% POINT FILTERING & MAP RECONSTRUCTION FROM POINT CLOUD
% (GRID ALIGNMENT + SEGMENT MERGING)
% ============================================================
% Author: Le Tran Duy Tan
% ----------------------------------
figure('Name','Filtered Map from LIDAR','Color','w');
hold on; grid on; axis equal;
xlabel('X (columns)'); ylabel('Y (rows)');
title('2D Map Reconstructed from LIDAR (Filtered Lines)');
xlim([0 25]); ylim([0 25]);

% --- Round data to grid ---
gridStep = 0.5; % grid cell size
points = round(lidarPoints / gridStep) * gridStep;

% --- Display raw points ---
plot(points(:,1), points(:,2), 'r.', 'MarkerSize', 4, 'DisplayName','Raw Points');

% --- Group by rows (Y values close together) ---
tolY = gridStep / 2;
tolX = gridStep / 2;
minLen = 3; % minimum number of points to form a wall

% ========== Filter horizontal segments ==========
for yVal = 0:gridStep:25
idx = abs(points(:,2) - yVal) < tolY;
if sum(idx) < minLen, continue; end
rowPts = sort(points(idx,1));

% group consecutive clusters
gaps = [true; diff(rowPts) > gridStep*1.5];
groupID = cumsum(gaps);
for g = unique(groupID)'
    seg = rowPts(groupID == g);
    if numel(seg) >= minLen
        plot([min(seg) max(seg)], [yVal yVal], 'b-', 'LineWidth', 2);
    end
end


end

% ========== Filter vertical segments ==========
for xVal = 0:gridStep:25
idx = abs(points(:,1) - xVal) < tolX;
if sum(idx) < minLen, continue; end
colPts = sort(points(idx,2));

% group consecutive clusters
gaps = [true; diff(colPts) > gridStep*1.5];
groupID = cumsum(gaps);
for g = unique(groupID)'
    seg = colPts(groupID == g);
    if numel(seg) >= minLen
        plot([xVal xVal], [min(seg) max(seg)], 'g-', 'LineWidth', 2);
    end
end


end

legend({'Raw Points','Horizontal Walls','Vertical Walls'},'Location','best');
disp('✅ Filtered map created — points converted into straight wall segments.');