%1 Crear un cuerpo rigido
body1 = rigidBody('body1');

%2 Crear una articulacion
jnt1 = rigidBodyJoint('jnt1','revolute');

%3 Definir una posicion inicial 
jnt1.HomePosition = pi/4;

%4 Configurar la transformacion de articulacion a padre
%usando una matriz de transformacion homogenea
tform = trvec2tform([0.25,0.25,0]);  %Definido por el usuario
setFixedTransform(jnt1,tform);

%5 Asignar la articulacion 1(jnt1) al cuerpo rigido 1(body)
body1.Joint=jnt1;

%6 Create a rigid body tree
robot = rigidBodyTree;

%7 Add the first body to the tree. Specify that you are 
%attaching it to the base of the tree
addBody(robot,body1,'base');

%{
8 Create a second body. Define properties of this body
%}
body2 = rigidBody('body2');
jnt2 = rigidBodyJoint('jnt2','revolute');
jnt2.HomePosition = pi/6;
%{
9 Attach the body2 to the first rigid body. Define the transformation 
relative to the previous body frame
%}
tform2 = trvec2tform([1,0,0]); %User define
setFixedTransform(jnt2,tform2);
body2.Joint = jnt2;
addBody(robot,body2,'body1');% Add body2 to body1



%10 Add other bodies. Attach body3 and 4 to body2

body3 = rigidBody('body3');
body4 = rigidBody('body4');
jnt3 = rigidBodyJoint('jnt3','revolute');
jnt4 = rigidBodyJoint('jnt4','revolute');

tform3 = trvec2tform([0.6, -0.1, 0])*eul2tform([-pi/2, 0, 0]); % User defined
tform4 = trvec2tform([1, 0, 0]); % User definedsetFixedTransform(jnt2,tform2);

setFixedTransform(jnt3,tform3);
setFixedTransform(jnt4,tform4);

jnt3.HomePosition = pi/4; % User defined
jnt4.HomePosition = pi/4; % User defined

body3.Joint = jnt3;
body4.Joint = jnt4;

addBody(robot,body3,'body2'); % Add body3 to body2
addBody(robot,body4,'body2'); % Add body4 to body2

%11 Add an end effector
bodyEndEffector = rigidBody('endeffector');
tform5 = trvec2tform([0.5,0,0]);
setFixedTransform(bodyEndEffector.Joint,tform5);
addBody(robot,bodyEndEffector,'body4');

config = randomConfiguration(robot);
tform = getTransform(robot,config,'endeffector','base');

newArm = subtree(robot, 'body2');
removeBody(newArm,'body3');
removeBody(newArm,'endeffector')

newBody1 = copy(getBody(newArm,'body2'));
newBody2 = copy(getBody(newArm,'body4'));
newBody1.Name = 'newBody1';
newBody2.Name = 'newBody2';
newBody1.Joint = rigidBodyJoint('newJnt1','revolute');
newBody2.Joint = rigidBodyJoint('newJnt2','revolute');
tformTree = trvec2tform([0.2, 0, 0]); % User defined
setFixedTransform(newBody1.Joint,tformTree);
replaceBody(newArm,'body2',newBody1);
replaceBody(newArm,'body4',newBody2);

addSubtree(robot,'body1',newArm);

showdetails(robot)