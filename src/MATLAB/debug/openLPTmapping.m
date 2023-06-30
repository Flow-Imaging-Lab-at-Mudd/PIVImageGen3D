clear
close all

imagePath = 'C:\Users\lmendelson\Documents\Data\OpenLPT\LPTtestNoRotSparse\data\cam1\01_01.txt';
calPath = 'C:\Users\lmendelson\Documents\Data\OpenLPT\LPTtestNoRotSparse\data\calibrationResultsLPT1.txt';
pointsPath = 'C:\Users\lmendelson\Documents\Data\OpenLPT\LPTtestNoRotSparse\eval\particles01.mat';

% Camera and frame to debug on
camNum = 1;
frame = 1;

% detected particle positions
pixelData = importdata(imagePath);
pixelData = reshape(pixelData,2,[]);
pixelData = pixelData';

figure(1)
plot(pixelData(:,1),pixelData(:,2),'o');
axis image
% xlim([0 1024])
% ylim([0 1024])
set(gca, 'YDir','reverse');
hold on

% known 3D particle positions projected through camera and in world
% coordinates
particles = load(pointsPath,'particleMapMulti','particleWorldMulti');

% voxel = particles.particleMapMulti;
% vx = voxel.allParticles.x(:,frame);
% vy = voxel.allParticles.y(:,frame);

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
calibrationResultsLPT1 = readtable("C:\Users\lmendelson\Documents\Data\OpenLPT\LPTtestNoRotSparse\data\calibrationResultsLPT1.txt", opts);

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

% get f_effective (focal length in pixels)
Find = calibrationResultsLPT1.Parameter == 'f_eff';
camParaCalib.f_eff = calibrationResultsLPT1.Value(Find);

% get distortion
Kind = calibrationResultsLPT1.Parameter == 'kx';
Kind2 = calibrationResultsLPT1.Parameter == 'kr';

%k1 is kr
camParaCalib.k1 = calibrationResultsLPT1.Value(Kind2);

% pixel and scale properties
Noh_ind = calibrationResultsLPT1.Parameter == 'Noffh';
Now_ind = calibrationResultsLPT1.Parameter == 'Noffw';
Nph_ind = calibrationResultsLPT1.Parameter == 'Npixw';
Npw_ind = calibrationResultsLPT1.Parameter == 'Npixh';

camParaCalib.Noffh = calibrationResultsLPT1.Value(Noh_ind);
camParaCalib.Noffw = calibrationResultsLPT1.Value(Now_ind);
camParaCalib.Npixh = calibrationResultsLPT1.Value(Nph_ind);
camParaCalib.Npixw = calibrationResultsLPT1.Value(Npw_ind);

% projection
% remaining issues in matching calibrations: z coordinate flip and 512
% pixel offset (principal point?)

% C++ projection for reference
% inline Position Camera::ImageToWorld(const Position& p) const
% {
% 	Position tmp(p * T.Z() / f_eff);
% 	Position proj(tmp.X(), tmp.Y(), T.Z());
% 	// return coordinates of p in 3D world coordinates
% 	//return ((proj - T) * R);
% 	return (Rinv * (proj - T));
% }
% 
% inline Position Camera::WorldToImage(const Position& p) const
% {
% 	//Position proj(p * Rinv + T);
% 	Position proj(R * p + T);
% 	return (proj * (f_eff / proj.Z())); 
% }

Xc = worldData * (camParaCalib.R)';

Xc(:,1) = Xc(:,1) + camParaCalib.T(1);
Xc(:,2) = Xc(:,2) + camParaCalib.T(2);
Xc(:,3) = Xc(:,3) + camParaCalib.T(3);

dummy = camParaCalib.f_eff ./ Xc(:,3);
Xu = Xc(:,1) .* dummy;  
Yu = Xc(:,2) .* dummy;

% undistorted image coordinates
ru2 = Xu .* Xu + Yu .* Yu;
dummy = 1 + camParaCalib.k1 * ru2;
Xd = Xu ./ dummy;
Yd = Yu ./ dummy;

% c++ undistortion for reference
% inline Position Camera::UnDistort(const Position& p) const
% {
% 	//Position centered(p);
% 	// shift origin to the center of the image
% 	//centered -= Position(Npixw/2, Npixh/2, 0);
% 	
% 	// account for left-handed coordinate system...
% 	Position centered(p.X() - Npixw/2 - Noffw, -p.Y() + Npixh/2 - Noffh, p.Z());
% 	
% 	// scale into physical units
% 	centered *= Position(wpix, hpix, 0);
% 	// remove possible cylindrical distortion
% 	// 	cout << corrframes[0] << endl;should this be 1.0/kx? i.e., should kx be bigger or smaller than 1?
% 	centered *= Position(kx, 1, 0);
% 	// compute the radial correction factor
% 	
% 	 // Old code
% 	
% 	if (kr == 0) 
% 		return centered;
% 	
% 	else {
% 		// New Code (accounting for radial distortion)
% 		double y = centered.Y();
% 		double x = centered.X();
% 		double a = centered.X() / centered.Y();
% 
% 		y = (1 - sqrt(1 - 4 * pow(y, 2) * kr*(pow(a, 2) + 1))) / (2 * y * kr * (pow(a, 2) + 1));
% 		x = a*y;
% 
% 		Position M(x, y, 0);
% 		return M;
% 	}
% }

% shifts
Xtest_proj(:,1) = Xd + camParaCalib.Noffw + camParaCalib.Npixw/2;
Xtest_proj(:,2) = camParaCalib.Npixh/2 - camParaCalib.Noffh - Yd;

%Xtest_proj(:,1) = Xd/camParaCalib.wpix + camParaCalib.Noffw + camParaCalib.Npixw/2;
%Xtest_proj(:,2) = camParaCalib.Npixh/2 - camParaCalib.Noffh - Yd/camParaCalib.hpix;

figure(1)
plot(Xtest_proj(:,1),Xtest_proj(:,2),'.');