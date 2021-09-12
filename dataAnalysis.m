%%% DATA ANALYSIS STUFF
% clear, clc


%%% EXPERIMENT INFORMATION
disp('Data per Experiment')
disp('-------------------')

% Experiment Duration and Sampling
experimentDuration = 600; % seconds (want to do -100 to 600 so leave 1 extra bit?)
experimentSampling = 100; % 100 samples/seconds

% Experiment Data (All sensors for 10 min experiment)
experimentClock = experimentDuration*experimentSampling; % total clock data
experimentBytes = minimumBytes(experimentClock);

% Experiments per orbit
% NEED TO CONFIRM THIS INFORMATION > I THINK ITS 2-3 EXPERIMENTS PER ORBIT
numExperiments = 3; % Number of experiments per orbit (30 min out of 90)
experimentDataTotal = experimentBytes*experimentClock/1e6;
clock_string = ['Clock:   ', num2str(experimentDataTotal), ' MB'];
disp(clock_string)
% USE THERMAL AND POWER SIM TO CONFIRM THIS^^^


%%% PAYLOAD DATA
% Pressure Accuracy
%{
pressureAccuracy = 0.00002; % Paper said they have 0.002% accuracy pressure transducers
pressureRange = 7e6; % Vapor Pressure of H20 is 1379 Pa so being on the safe side here
pressureBytes = minimumBytes(pressureRange/pressureAccuracy);
disp(pressureBytes)
% This will give us 13 bits > error at 1e8 is 1.4901e-08
% Just use double-precision because error is less than 1e-7 (within needs)
%}

% Velocity Accuracy
% Output should be similar to before > just use double-precision
% Also where do I find data on SLOSHSat? I want to see what they used
% In terms of pressure and velocity sensors at least

% Accelerometer Accuracy
%{
accelerometerAccuracy = 1e-6;
accelerometerRange = 360;
accelerometerBytes = minimumBytes(accelerometerRange/accelerometerAccuracy);
disp(accelerometerBytes)
% This will give us 10 bytes > error is 1e-6
% Just use double-precision because error is less than 1e-7 (within needs)
%}

% Gyroscope Accuracy
% NOT DOING THIS ONE, I'M EXPECTING THE SAME RESULT AS ACCELEROMETER
% SHOULD BE FINE USING DOUBLE-PRECISION (even floating-point)

% Sensors and Commands Information
% Format: (Column 1: Bytes for Sensor, Column 2: Number of Sensors/Data Points)
sensorStats = [
    4, 3;       % Command > floating-point > 3 values of desired attitude
    4, 4;       % Reaction Wheel > floating-point > 4 wheel speeds to track
    4, 24;      % Pressure > floating-point > 24 sensors (1)
    4, 24;      % Velocity > floating-point > 24 sensors (1)
    4, 3*2;     % Accelerometer > floating-point > 3 axis w/ 2 sensors each
    4, 3*2;     % Gyroscope > floating-point > 3 planes w/ 2 sensors each
    4, 3;       % Star Tracker > floating-point > 3 values (attitude)
    % CHECK STAR TRACKER INFO^^ > Does it need to measure this fast?
];
% 1) Cylindrical Tank with Spherical End Caps
%   Get 6 symmetric sections (slices) > Each slice has 4 sections
%   1 Left Sphere, 2 Cylinder, 1 Right Sphere > Total 24 sensors

% Sensor Data (All sensors for 10 min experiment)
sensorsOneDataPoint = sum(sensorStats(:,1).*sensorStats(:,2));
sensorDataTotal = sensorsOneDataPoint*experimentClock/1e6;
sensor_string = ['Sensors: ', num2str(sensorDataTotal), ' MB'];
disp(sensor_string)


%%% SATELLITE STATUS DATA
disp(' ')
disp('Satellite Data per Orbit')
disp('------------------------')

% Satellite Status and Health
% Format: (Column 1: Range, Column 2: Decimal Accuracy, Column 3: Number of Sensors, Column 4: Measurements/Orbit)
statusStats = [
    10*365*24*60*60, 3, 1, 100;         % Time > 10 yrs, 3 decimals, 1 clock, max of 100/orbit
    400, 2, 10, 90*60;                  % Temperature > 0-400K, 1 decimal, 10 places, 1 value/second (1)
    100, 2, 2, 90*60;                   % Battery > 0-100%, 1 decimal, 2 batteries, 1 value/second (2)
    8, 0, 1, 90*60;                     % Operation Mode > 8 modes, no decimal, 1 mode, Clock? (3)
    % WHAT OTHER THINGS DO WE NEED TO MONITOR THE SPACECRAFT
];
% 1) 10 sensors > computer, tank, battery *2, antenna *2, solar panels *4, 
% 2) Assuming 2 batteries (for redundancy)
% 3) 8 modes > Safe, Detumble, Charging, Heating, Cooling, Communication, Experiment, Error

statusDataTotal = sum(statusStats(:,4).*statusStats(:,3).*minimumBytes(statusStats(:,1)./(10.^-statusStats(:,2))))/1e6;
status_string = ['Status:  ', num2str(statusDataTotal), ' MB'];
disp(status_string)


%%% TOTAL ORBIT INFORMATION
disp(' ')
disp('Total Data per Orbit')
disp('--------------------')
totalData = experimentDataTotal + sensorDataTotal + statusDataTotal;
total_string = ['Total:   ', num2str(totalData), ' MB'];
disp(total_string)


%%% FUNCTIONS
% Calculate minimum bits needed for certain data representation
function minBytes = minimumBytes(data)
    minBytes = ones(length(data), 1);
    % disp('min bytes')
    for a = 1:length(data)
        % disp(minBytes)
        while (data(a) > 8^minBytes(a))
            minBytes(a) = minBytes(a) + 1;
        end
    end
end


