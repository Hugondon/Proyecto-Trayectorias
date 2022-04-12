% The script was used to generate test trajectories

%% Import Setup
nameTrajectory='thunder_test';

% Get positions declare w.r.t Global reference (Robot base)
% Load struct with positions and orientations
load Test_trajectories/thunder.mat

%% Trajectory processing

% Create Trajectory modifiers(only displacement and stretching not rotation)
trajectoryModiefiers.stretch=[1,1,1];
trajectoryModiefiers.offset=[0,0,0];

% Changing trajectories with the modifiers
positions_m(:,1)    =   trajectoryModiefiers.stretch(1)*...
                        positions_m(:,1)+...
                        trajectoryModiefiers.offset(1);
positions_m(:,2)    =   trajectoryModiefiers.stretch(2)*...
                        positions_m(:,2)+...
                        trajectoryModiefiers.offset(2);
positions_m(:,3)    =   trajectoryModiefiers.stretch(3)*...
                        positions_m(:,3)+...
                        trajectoryModiefiers.offset(3);

%% Generate orientations
% Get number of positions
number_waypoints = size(positions_m, 1);

% Single orientation
orientations= ones(number_waypoints,1)*[0, 1, 0, pi];


%% Plot Trajectory
plot3(positions_m(:,1),positions_m(:,2),positions_m(:,3))
grid on

%% Save Trajectory

% Save?
elec=input("Save Y/N \n",'s');
if (elec=='Y' || elec=='y')
    % Path to save trajectory
   save(['Test_trajectories/',nameTrajectory,'.mat'],'positions_m','orientations') 
end