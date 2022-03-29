handle.a = axes;
% generate random x,y,z values
handle.x = randi([1 10],1,5);
handle.y = randi([1 10],1,5);
handle.z = randi([1 10],1,5);
% plot in 3D
handle.p = plot3(handle.x,handle.y,handle.z,'.');
xlabel('x-axis');
ylabel('y-axis');
zlabel('z-axis');

infoFigura.lista=0;

guidata(handle.p,infoFigura);
% add callback when point on plot object 'handle.p' is selected
% 'click' is the callback function being called when user clicks a point on plot
handle.p.ButtonDownFcn= {@click,handle};



% definition of click
function click(obj,eventData,handle)
    % co-ordinates of the current selected point
    Pt = handle.a.CurrentPoint(2,:);
    % find point closest to selected point on the plot
    for k = 1:5
        arr = [handle.x(k) handle.y(k) handle.z(k);Pt];
        distArr(k) = pdist(arr,'euclidean');
    end
    [~,idx] = min(distArr);
     
    point=[handle.x(idx) handle.y(idx) handle.z(idx)];
    %disp(idx)
    %data.lista(end+1,1)=idx
    writematrix(point,'puntos.csv','WriteMode', 'append','Delimiter','comma');
  
    disp(point);
    %saveData(lista,idx);
    %lista(end+1,1)=idx;
    % display the selected point on plot
    %disp([handle.x(idx) handle.y(idx) handle.z(idx)]);
end