% First try for csv convertion

clear, clc, clear all

FILENAME = 'coordinates.csv';
x_coordinates_m = 1:5;
y_coordinates_m = 10:15;
z_coordinates_m = 20:25;
angles_radians = 30:35;

% Mustn't be changed to [] although warning says so.
column_names = {"X coordinate [m]", "Y coordinate [m]", "Z coordinate [m]", "Angle [radians]"};

% Writes row containing column headers.
writecell(column_names, FILENAME, 'WriteMode', 'overwrite');

number_of_columns = size(angles_radians, 2);

for count = 1:number_of_columns - 1
    data = [x_coordinates_m(count) y_coordinates_m(count) z_coordinates_m(count) angles_radians(count)];
%     Writes data as new row.
    writematrix(data, FILENAME, 'WriteMode', 'append');
end
