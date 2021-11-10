
% Script to generate trajectories    
nameTrajectory='hola_mundo_v2';

% Get positions declare w.r.t Global reference (Robot base)
%      positions_m =... [0,-0.3,0.55] 
%  [-0.300000000000000,-0.300000000000000,0.450000000000000;0,-0.300000000000000,0;-0.300000000000000,0,0];
%  % Get orientations (in rotation vector)
% orientations = [0, 1, 0, pi; ...
%                 0, 1, 0, pi; ...
%                 0, 1, 0, pi; ...
%                 0, 1, 0, pi];
load Test_trajectories/hola_mundo.mat
positions_m(:,2)= positions_m(:,2)+0.64;
positions_m(:,3)= positions_m(:,3)*0.6;

positions_m(:,3)= positions_m(:,3)+0.15;

% Get number of positions
number_waypoints = size(positions_m, 1);

% Single orientation
orientations= ones(number_waypoints,1)*[0, 1, 0, pi];


%Plot Trajectory
plot3(positions_m(:,1),positions_m(:,2),positions_m(:,3))
grid on

%% Save Trajectory

% Save?
elec=input("Save Y/N \n",'s');
if (elec=='Y' || elec=='y')
    % Path to save trajectory
   save(['Test_trajectories/',nameTrajectory,'.mat'],'positions_m','orientations') 
end