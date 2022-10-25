%% User selected variables
% Use JPG format
nameImage = 'quanser.jpg';
physicalSize_m=150E-3;
reductionConstant = 1; %3;
numLowPointsThreshold = 0; %10
numHighPointsThreshold = 700; %600
eliminatedObject = 0;

%% Importing image
path = ['Imagenes\', nameImage];
image = imread(path);

%% Process image
% Turn it to grayscale
imageGray=im2gray(image);
% Binarize grayscale image
BW = imbinarize(imageGray);
BWcolors = imbinarize(image);
%BW = or(BWcolors(:,:,1),BWcolors(:,:,2));
% Get boundaries of objects
[B,L]  = bwboundaries(imrotate(BW,180),'holes');
[Bup,Lup] = bwboundaries(BW,'holes');

%% Binarize by colors
BWcolors = imbinarize(image);

% Plot original image and binarize colors images
% figureBinarizeColors = figure('Name','Binarize Colors','NumberTitle','off');
% %Original
% subplot(2,2,1)
% imshow(image);
% % Red Image
% subplot(2,2,2)
% imshow(BWcolors(:,:,1));
% % Green Image
% subplot(2,2,3)
% imshow(BWcolors(:,:,2));
% % Blue Image
% subplot(2,2,4)
% imshow(BWcolors(:,:,3));

%% Check if objects are small
% Minimum pixel perimeter to be consider an object

% Current quantity of objects in the image
numObjects=length(B);
% List of elements to be erased
listObjectsToErase=[];

% Iterates through cell array if an element is smaller than threshold it saves its index
for cont = 1:numObjects
   numPoints = length(B{cont});
   if (numPoints<numLowPointsThreshold ||numPoints>numHighPointsThreshold || cont== eliminatedObject)
        listObjectsToErase(end+1)=cont;
   end
end

% Quantity of objects to erase
numObjectsToErase=length(listObjectsToErase);
% If there is at least one object to erase it executes
if (numObjectsToErase>0)
    B(listObjectsToErase)=[];
    numObjects = numObjects-numObjectsToErase;
end

%% Plot Binarize gray image
figureBinarizeBW = figure('Name','Binarize B/N','NumberTitle','off');
% Show original image
subplot(2,2,1)
imshow(image);
% Show gray image
subplot(2,2,2)
imshow(imageGray);
% Show Binarize image
subplot(2,2,3)
imshow(BW);
% Show boundaries of objects in image
subplot(2,2,4)

% figure
imshow(label2rgb(Lup, @jet, [.5 .5 .5]));
hold on
for k = 1:numObjects
   boundary = Bup{k};
   plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2);
end

% Eliminate later
% close all
%% From image space to 3D space
figure3DSpace = figure('Name','Image in Workspace','NumberTitle','off');
hold on
grid on


imagePoses = cell(length(B),1);
for cont = 1:numObjects
   boundary = B{cont};
   boundary = boundary(1:reductionConstant:end,:);
   boundary(end+1,:) = boundary(1,:);
   sizeBoundaries=length(boundary);
   imagePoses{cont}=double(trvec2tform([boundary(:,2),zeros(sizeBoundaries,1),boundary(:,1)]));
end


%% Image correction and adjustment
sizeCorrection = eye(4);
sizeCorrection(4,4) =  length(image)/physicalSize_m;


for cont = 1:numObjects
    % Scaling corrections
    imagePoses{cont}=pagemtimes(sizeCorrection,imagePoses{cont});
    imagePoses{cont}(:,4,:)=imagePoses{cont}(:,4,:)/sizeCorrection(4,4);
    % Orientation corrections
    imagePoses{cont} = pagemtimes(axang2tform([0,0,1,pi/2]),imagePoses{cont});
    % Rounding error correction
    numPoints = length(imagePoses{cont});
    for contPoints = 1:numPoints
        imagePoses{cont}(1,4,contPoints) = 0;
    end
    % Add aproching Pose
    aprochingPose = imagePoses{cont}(:,:,1)*trvec2tform([0,0.05,0]);
    imagePoses{cont}= cat(3,aprochingPose,cat(3,imagePoses{cont},aprochingPose));
end
%% Insert starting pose
imageHeight = size(image,1);
imageWidth = size(image,2);
if(imageWidth>imageHeight)
    correctionCoefficientStartPose = imageHeight/imageWidth;
elseif(imageWidth<=imageHeight)
    correctionCoefficientStartPose = 1;
end

supportCellArray=imagePoses;
startPoses=zeros(4,4,2);
startPoses(:,:,1)=axang2tform(tform2axang(imagePoses{1}(:,:,1)))*trvec2tform([0,0,correctionCoefficientStartPose*physicalSize_m]);
startPoses(:,:,2)= startPoses(:,:,1)*trvec2tform([0,0.05,0]);
imagePoses={startPoses,supportCellArray{:},startPoses(:,:,2:-1:1)}';
% imagePoses = supportCellArray;
clear supportCellArray
numObjects = numObjects+2;
for cont = 1:numObjects
   imagePoints = tform2trvec(imagePoses{cont});
   plot3(imagePoints(:,1),imagePoints(:,2),imagePoints(:,3));
end
view([-1,0,0]);
% view([-1,1,0]);



% Hasta aqui todo bien




% distVector=[0;0;0];
% rotationMatrix = eye(3);
% 
% for contObjects = 1:numObjects
%    numPoints=length(imagePoses{contObjects});
%    rotationMatrix(:,3) = [0;-1;0];
%    for contPoints = 1:numPoints-1
%         % Distance between poses
%         distVector = tform2trvec(imagePoses{contObjects}(:,:,contPoints+1))-tform2trvec(imagePoses{contObjects}(:,:,contPoints));
%         % Unit distance vector 
%         rotationMatrix(:,1) = distVector/vecnorm(distVector);
%         % Y unit Vector
%         rotationMatrix(:,2) = cross(rotationMatrix(:,3),rotationMatrix(:,1));
%         rotationMatrix(:,3) = cross(rotationMatrix(:,1),rotationMatrix(:,2));
%         imagePoses{contObjects}(1:3,1:3,contPoints) = rotationMatrix;
%    end
%    % Close the object boundary adding another starting point at the end, orientation added
%    imagePoses{contObjects}(:,:,end) = imagePoses{contObjects}(:,:,1);
% end
% for contObjects = 1:numObjects
%     numPoints=size(imagePoses{contObjects},3);
%     objectPoses=imagePoses{contObjects};
%     for contPoints = 1:numPoints
%         plotTransforms(tform2trvec(objectPoses(:,:,contPoints)),tform2quat(objectPoses(:,:,contPoints)), 'FrameSize', 0.02);
%     end
% end
% 
totalNumberPoses=0;
for contObjects = 1:numObjects
    totalNumberPoses = totalNumberPoses + size(imagePoses{contObjects},3);
end
%
waypoints = zeros(4,4,totalNumberPoses);
sumNumWaypoints = 0;
eraseList=[];
for contObjects = 1:numObjects
    numPoints=size(imagePoses{contObjects},3);
    objectPoses=imagePoses{contObjects};
    for contPoints = 1:numPoints
        if((sumNumWaypoints>0 & waypoints(:,:,contPoints+sumNumWaypoints-1)==objectPoses(:,:,contPoints)))
            eraseList(end+1) = contPoints+sumNumWaypoints;
        elseif (sum(objectPoses(:,:,contPoints),"all") == 0)
            eraseList(end+1) = contPoints+sumNumWaypoints;
        end
        waypoints(:,:,contPoints+sumNumWaypoints) = objectPoses(:,:,contPoints);
    end
    sumNumWaypoints = sumNumWaypoints + numPoints;
end
if (length(eraseList)>0)
   waypoints(:,:,eraseList) = [];
end
disp(nameImage);
disp(length(waypoints));
save('waypoints.mat','waypoints');


