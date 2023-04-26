clear

imagePath = 'C:\Users\lmendelson\Documents\Data\OpenLPT\LPTtest\data\cam1\01_01.txt';
calPath = 'C:\Users\lmendelson\Documents\Data\OpenLPT\LPTtest\data\calibrationResultsLPT1.txt';
pointsPath = 'C:\Users\lmendelson\Documents\Data\OpenLPT\LPTtest\eval\particles01.mat';

% Camera and frame to debug on
camNum = 1;
frame = 1;

% detected particle positions
pixelData = importdata(imagePath);
pixelData = reshape(pixelData,2,[]);

% known 3D particle positions projected through camera
particles = load(pointsPath,'particleWorldMulti');
particles = particles.particleWorldMulti;
px = particles.x(:,frame);
py = particles.y(:,frame);
pz = particles.z(:,frame);
worldData = [px py pz];

% read calibration from text file
fid = fopen(calPath,'r');

count_flag = 0; % look for number of cameras
line = 0;
while count_flag == 0
    tmp = fgetl(fid);
    line = line+1;
    count_flag = contains(tmp,'camera number');
end

cam_flag = 0; % look for specified camera to debug

while cam_flag == 0
    tmp = fgetl(fid);
    line = line+1;
    cam_flag = contains(tmp,['camera ' num2str(camNum)]);
end

% start reading following header for chosen camera
%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 2);

% Specify range and delimiter
opts.DataLines = [line+1, line+1+32];
opts.Delimiter = "#";

% Specify column names and types
opts.VariableNames = ["Value", "Parameter"];
opts.VariableTypes = ["double", "categorical"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "Parameter", "EmptyFieldRule", "auto");

% Import the data
calibrationResultsLPT1 = readtable("C:\Users\lmendelson\Documents\Data\OpenLPT\LPTtest\data\calibrationResultsLPT1.txt", opts);

%% Clear temporary variables
clear opts

% create R array
Rind = calibrationResultsLPT1.Parameter == 'R';
Rvalues = calibrationResultsLPT1.Value(Rind);
camParaCalib.R = reshape(Rvalues,3,3);

% create T array
Tind = calibrationResultsLPT1.Parameter == 'T';
Tvalues = calibrationResultsLPT1.Value(Tind);
camParaCalib.T = Tvalues;

% get f_effective
Find = calibrationResultsLPT1.Parameter == 'f_eff';
camParaCalib.f_eff = calibrationResultsLPT1.Value(Find);

% get distortion
Kind = calibrationResultsLPT1.Parameter == 'kx';
camParaCalib.k1 = calibrationResultsLPT1.Value(Kind);

Xc = worldData * (camParaCalib.R)';
Xc(:,1) = Xc(:,1) + camParaCalib.T(1);
Xc(:,2) = Xc(:,2) + camParaCalib.T(2);
Xc(:,3) = Xc(:,3) + camParaCalib.T(3);
dummy = camParaCalib.f_eff ./ Xc(:,3);
Xu = Xc(:,1) .* dummy;  % undistorted image coordinates
Yu = Xc(:,2) .* dummy;
ru2 = Xu .* Xu + Yu .* Yu;
dummy = 1 + camParaCalib.k1 * ru2;
Xd = Xu ./ dummy;
Yd = Yu ./ dummy;