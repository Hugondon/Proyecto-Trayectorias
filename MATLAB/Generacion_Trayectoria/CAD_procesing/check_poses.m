load processedCAD.mat
pdegplot(gm);
hold on
numPoses=size(surfacePathPoses,3);
for contPose=1:numPoses
    plotTransforms(tform2trvec(surfacePathPoses(:,:,contPose)),tform2quat(surfacePathPoses(:,:,contPose)), 'FrameSize', 0.01*5);
    %hold on
    waitforbuttonpress;
end