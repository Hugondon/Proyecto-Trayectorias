function transformedCAD = processedCADTransformation(processedCAD,displacementVector,rotationVector)
    %PROCESSEDCADTRANSFORMATION Summary of this function goes here
    %   Detailed explanation goes here
    %% Default arguments
    arguments
        processedCAD        struct;
        displacementVector  (1,3) = [0,0,0];
        rotationVector      (1,4) = [1,0,0,0];
    end
    %% Reference Frame Transformtation
    % Create Homogenous Transformation Matrix
    transformationMatrix = trvec2tform(displacementVector)*axang2tform(rotationVector);
    % Transform the Reference Frame of the Geometric Model
    transformedCAD.ReferenceFrame = transformationMatrix*processedCAD.ReferenceFrame;

    %% Geometric Model Transformation
    % In a Homogenius Transformation you translate and then rotate, for some reason in this case it
    % must be done in reverse otherwise it makes it wrong.

    % Rotate Geometric Model
    transformedCAD.DiscreteGeometry = rotate(processedCAD.DiscreteGeometry,rad2deg(rotationVector(1,4)),[0,0,0],rotationVector(1,1:3));
    % Translate Geometric Model
    transformedCAD.DiscreteGeometry = translate(processedCAD.DiscreteGeometry,displacementVector);
    
    %% Pose Path Transformation
    % Transform the Surface Pose Path
    transformedCAD.SurfacePathPoses = pagemtimes(transformationMatrix,processedCAD.SurfacePathPoses);
end

