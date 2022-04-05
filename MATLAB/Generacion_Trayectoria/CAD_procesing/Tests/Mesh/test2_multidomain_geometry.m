% Source:
% https://www.mathworks.com/help/pde/ug/split-geometry-into-subdomains-using-geometryfrommesh.html
% File format .STL

% Create PDE model
msd1= createpde;
msd2= createpde;

% Import STL into the PDE model
gm1=importGeometry(msd1,'Part\cilindro_r100_h400_mm.STL');
gm2=importGeometry(msd2,'Part\cilindro_ranura_r100_h200_mm.STL');

msh1=generateMesh(msd1);
msh2=generateMesh(msd2);

pdeplot3D(msh1)
hold on
pdeplot3D(msh2)
