function obstCell = setObstacles()
%SETOBSTACLES Set the obstacles on the figure to create the RRT

%{
Create a Cell Array of obstacles in the workspace.
    Input:
        -
    Output:
        obstCell:   Cell array that collision box and pose of each obstacle
%}
    
    %% Create Obstacle Cell Array
    % Number of obstacles (Determined by the user)
    numObst=2;
    % Create Obstacle Cell Array
    obstCell=cell(1,numObst);
    
    %% Fill Obstacle Cell Array
    
    %Obstacle N:
    %Shape
    %Pose

    % Obstacle 1: Platform
    obstCell{1,1}=collisionBox(1, 0.5, 0.05); % X Y Z
    obstCell{1,1}.Pose = trvec2tform([0,0,-0.05])*axang2tform([1 0 0 0]);
    
    % Obstacle 2: Sphere
    obstCell{1,2}=collisionSphere(0.1);         % R
    obstCell{1,2}.Pose = trvec2tform([-0.5,0,0.5])*axang2tform([1 0 0 0]);
end

