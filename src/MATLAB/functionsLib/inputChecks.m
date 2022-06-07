% Camera input checks
if ~exist('arrayName','var')
    error('"arrayName" variable for camera array name must be set.')
end

% Occlusion input checks
if occluded
    if ~isfield(body,'file')
        error('"body.file" variable for occlusion .stl must be set')
    end

    if ~isfield(body,'scale')
        warning('"body.scale" variable for occlusion scale not set. Using default of 1')
        body.scale=1;
    end

    if ~isfield(body,'Position')
        warning('"body.Position" variable not set. Using default of [0 0 0]')
        body.position=[0 0 0];
    end

    if ~isfield(body,'Shade')
        warning('"body.Shade" variable not set. Using default of bright occlusion')
        body.shade=1;
    end
end

% PIV parameter input checks
if ~exist('baseOutput','var')
    warning('"baseOutput" variable not defined. Using default output path of ../../out/')
    baseOutput = '../../out';
end
if ~exist('flows','var')
    error('"flows" variable must be set. Defines the flows to generate.');
end
if ~exist('bitDepths','var')
    warning('"bitDepths" variable not defined. Defines the image bit depths.');
    warning('"bitDepths" variable will use default value of single 8-bit depth set.');
    bitDepths=8;
end
if ~exist('Ni','var')
    error('"Ni" variable must be set. Defines the volume particle concentration');
end
if ~exist('deltaXFactor','var')
    error('"deltaXFactor" variable must be set. Defines the IA displacement factors');
end
if ~exist('particleRadius','var')
    error('"particleRadius" variable must be set. Define the particle radiuses (px)');
end
if ~exist('noiseLevel','var')
    error('"noiseLevel" variable must be set. Defines the noise levels in (dB)');
end
if ~exist('outOfPlaneStdDeviation','var')
    error('"outOfPlaneStdDeviation" variable must not be empty');
end
if ~exist('numberOfRuns','var')
    warning('"numberOfRuns" variable not defined using default value of 1.');
    numberOfRuns = 1;
end

if isempty(flows)
    error('"flows" variable must not be empty');
end
if isempty(Ni)
    error('"Ni" variable must not be empty');
end
if isempty(deltaXFactor)
    error('"deltaXFactor" variable must not be empty');
end
if isempty(particleRadius)
    error('"particleRadius" variable must not be empty');
end
if isempty(noiseLevel)
    error('"noiseLevel" variable must not be empty');
end
if isempty(outOfPlaneStdDeviation)
    error('"outOfPlaneStdDeviation" variable must not be empty');
end
if ~exist('winSize','var')
    error('"winSize" variable must be set. Define the final interrogation window size (1 dimension)')
end
if ~exist('sheetThickness','var')
    error('"sheetThickness" variable must be set. Define the final interrogation window size (1 dimension)')
end
if ~exist('zWinScale','var')
    warning('"zWinScale" variable not defined using default value of 1.');
end

if numberOfRuns < length(outOfPlaneStdDeviation)
    warning('Adjusting numberOfRuns to match number of outOfPlaneStdDeviation combinations');
    numberOfRuns = length(outOfPlaneStdDeviation);
end

if ~exist('displayFlowField', 'var')
    warning('"displayFlowField" not set. Using default value of true');
    displayFlowField = true;
end

if ~exist('closeFlowField', 'var')
    warning('"closeFlowField" not set. Using default value of true');
    closeFlowField = true;
end

if mod(sizeX,winSize)~=0
    error('Image size must be divisible by final window size');
end

if mod(sizeY,winSize)~=0
    error('Image size must be divisible by final window size');
end

if mod(sheetThickness/scale,winSize)~=0
    error('Light sheet thickness must be divisible by final window size');
end