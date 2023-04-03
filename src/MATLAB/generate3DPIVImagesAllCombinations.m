inputChecks;

scaleProps.X = sizeX;
scaleProps.Y = sizeY;
scaleProps.perpix = scale;

writeCamConfig(cams,arrayName,baseOutput,scaleProps,camCombos);
writeCamConfigLPT(cams,arrayName,baseOutput,scaleProps,camCombos);

% load occlusion and write occlusion position and mesh to file
if occluded
    tmp = stlread(body.file);
    rescaled = tmp.Points*body.scale;
    body.Points = rescaled;
    tmpCentroid = mean(body.Points);
    shift = body.Position - tmpCentroid;
    body.Points = body.Points+shift;
    body.ConnectivityList = tmp.ConnectivityList;
    writeOcclusion(baseOutput,body,arrayName);
end

totalCombinations = size(flows, 2)*length(deltaXFactor)*length(bitDepths)* ...
    length(particleRadius)*length(Ni)*length(noiseLevel)*length(winSize)*length(sheetThickness)*numberOfRuns;

tStart = tic();

currentCombination=1;
for i=1:size(flows, 2)
    for deltaXFactorIndex=1:length(deltaXFactor)
        for bitResIndex=1:length(bitDepths)
            for particleRadiusIndex=1:length(particleRadius)
                for NiIndex=1:length(Ni)
                    for noiseLevelIndex=1:length(noiseLevel)
                        for outOfPlaneStdDeviationIndex = 1:length(outOfPlaneStdDeviation)
                            for winSizeIndex = 1:length(winSize)
                                for sheetThickIndex = 1:length(sheetThickness)
                                    for run = 1:numberOfRuns
%                                         outOfPlaneStdDeviationIndex = outOfPlaneStdDeviationIndex + 1;
%                                         if outOfPlaneStdDeviationIndex == length(outOfPlaneStdDeviation) + 1
%                                             outOfPlaneStdDeviationIndex = 1;
%                                         end
                                        clear flowParameters;
                                        clear pivParameters;                            
                                        clear flowField;
                                        clear particleMap;
                                        clear Im0;
                                        clear Im1;
                                        
                                        flowParameters={};
                                        flowParameters.maxVelocity=1000;     %Maximum velocity in mm/s for both u and v components - 1000.0 mm/s
                                        %No particle should displace more than 50% of the interrogation area
                                        %linear size (DI). In fact maximum displacement will be 25% of DI.
                                        flowParameters.deltaXFactor = deltaXFactor(deltaXFactorIndex); %deltaX/DI up to 0.25, (0.05, 0.10, 0.25), no interest in 0 displacement
                                        flowParameters.flowType=flows{i};
                                        flowParameters.display=displayFlowField;
                                        flowParameters.close=closeFlowField;

                                        if strcmp(flows{i},'vortex_ring')
                                            flowParameters.dimField(i) = 3; 
                                        else
                                            flowParameters.dimField(i) = 2; % dimensions of velocity field
                                        end
                                   

            
                                        %dt - 100us - 1000us
                                        pivParameters={};
                                        pivParameters.bits = bitDepths(bitResIndex); % 10, 12
                                        pivParameters.intensityMethod='clip'; %This will clip the values at 8-bit - 10-bit, 12-bit
                                                                              %range
                                        %pivParameters.intensityMethod='normalize'; %This will scale down all pixel intensities in both images,
                                                                             %so that the maximum is within the
                                                                             %8bit range
                                        pivParameters.renderRadius=20;       %Radius (square) in pixels for rendering a particle
                                        pivParameters.particleRadius=particleRadius(particleRadiusIndex);    %Particle radius - 0.5px - 3px 
                                        pivParameters.Ni=Ni(NiIndex);        %Particles per PIV last step IA window area   -   1 - 16
                                        maxValue = 2^pivParameters.bits-1;
                                        pivParameters.particleIntensityPeak=150.0*maxValue/255.0; %Particle intensity at the center of the light sheet (75% a 100%)
                                        pivParameters.noiseLevel=noiseLevel(noiseLevelIndex);%30;         %dBW (10 log (V^2)) - 20dBW -> 10 intensity variation
            
                                        pivParameters.lastWindow=[winSize(winSizeIndex) winSize(winSizeIndex) zWinScale*winSize(winSizeIndex)];    %Last PIV Window size (no overlap) - (y;x;z)
                                        pivParameters.laserSheetThickness=sheetThickness(sheetThickIndex); %2mm laser sheet thickness
            
                                        pivParameters.outOfPlaneStdDeviation=outOfPlaneStdDeviation(outOfPlaneStdDeviationIndex); %Out of plane velocity standard devitation in mm/frame - (0.025, or 0.05, or 0,10 mm)
                                        pivParameters.noMoveOutOfIA=false;   %Should particles be allowed to move in/out
                                                                             %of their respective Interrogation Area
                                        pivParameters.singlePart = singlePart; % Whether to bypass seeding setting to generate single particle images for normalization
            
                                        imageProperties={};
%                                         imageProperties.marginsX=2*pivParameters.lastWindow(2);
%                                         imageProperties.marginsY=2*pivParameters.lastWindow(1);
%                                         imageProperties.marginsZ=2*pivParameters.lastWindow(3);

                                        imageProperties.marginsX=0;
                                        imageProperties.marginsY=0;
                                        imageProperties.marginsZ=0;

                                        imageProperties.sizeX=sizeX + imageProperties.marginsX;
                                        imageProperties.sizeY=sizeY + imageProperties.marginsY;

                                        imageProperties.mmPerPixel=scale;
                                        imageProperties.voxPerSheet=pivParameters.laserSheetThickness / imageProperties.mmPerPixel + imageProperties.marginsZ;
                                        imageProperties.nFrames = numberOfFrames;
            
                                        DI = single(pivParameters.lastWindow(1)) * imageProperties.mmPerPixel;
                                        dtao = 2.0 * single(pivParameters.particleRadius) * imageProperties.mmPerPixel;
                                        pivParameters.c = single(pivParameters.Ni) / (DI^2 * zWinScale * DI); % concentration (particles per mm3)
                                        pivParameters.Ns = single(pivParameters.Ni)/(4.0/pi*DI/dtao); % source density
            
                                        disp(['Generating combination ' num2str(currentCombination) ' of ' num2str(totalCombinations)]);
                                        [~, particleMap, flowField] = generatePIVImagesMultiCam(flowParameters, imageProperties, pivParameters,...
                                            run, cams, arrayName, baseOutput, occluded, body);
                                        currentCombination = currentCombination + 1;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

tEnd = toc(tStart);
disp(['Completed all ' num2str(totalCombinations) ' combination(s) in: ' num2str(tEnd) ' seconds']);
