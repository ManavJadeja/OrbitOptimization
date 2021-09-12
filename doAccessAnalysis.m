%%% ACCESS DATA ANALYSIS
% Compute access between objects (satellite > facility)
access = satellite.GetAccessToObject(sensor);
access.ComputeAccess();

%Get computed access intervals
intervalCollection = access.ComputedAccessIntervalTimes;
computedIntervals = intervalCollection.ToArray(0, -1);
access.SpecifyAccessIntervals(computedIntervals);
disp(computedIntervals)
disp("Access Computed")

% Get Access Data
accessDP = access.DataProviders.Item('Access Data').Exec(scenario.StartTime, scenario.StopTime);
accessDuration = cell2mat(accessDP.DataSets.GetDataSetByName('Duration').GetValues);
% disp(accessDuration) % Uncomment only if its not too long
%{
% DP results return cell data types.  cell2mat
accessStartTimes = cell2mat(accessDP.DataSets.GetDataSetByName('Start Time').GetValues);
accessStopTimes = cell2mat(accessDP.DataSets.GetDataSetByName('Stop Time').GetValues);
%}

% Total Communication Duration
totalTime = sum(accessDuration, 'all');
disp(['Total Time (sec): ', num2str(totalTime)])
disp(['Total Time (min): ', num2str(totalTime/60)])
disp(['Total Time (hrs): ', num2str(totalTime/60/24)])

% Histogram of Access Durations (to see variability)
histogram(accessDuration, 10)

% Data Analysis (run script)
disp('Data Analysis')
disp('-------------')
dataAnalysis
disp('-------------')

% Data Rate and the Related
disp('Data Rate')
n = 2; % Safety Factor (assuming terrible conditions or something idk)
dataRate = (totalData*6000/totalTime)*(1/n);
% Want dataRate (MBps), have totalData (MB/orbit) + totalTime (year in seconds)
% So to get MBps, we multiply by orbits/year (i think its 6000 orbits/year) 
disp([num2str(dataRate), ' MBps'])
