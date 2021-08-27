clc, clear

%%%%%%%%%%%%%%%%%%%%%%%
% % %%%%%%%%%%%%%%% % % 
    MasterTnum = 10; % % By Changing this number you can instantly alter
% % %%%%%%%%%%%%%%% % % the number of targets that will be generated.
%%%%%%%%%%%%%%%%%%%%%%%

%% This section will check for running applications of STK and create a new scenario based on 3 paths
%integration, pro
disp('* Grabbing/creating instance of STK and creating a new scenario *')
tic

try
    % Grab an existing instance of STK
    uiapp = actxGetRunningServer('STK12.application');
    root = uiapp.Personality2;
    checkempty = root.Children.Count;
    if checkempty == 0
        %If a Scenario is not open, create a new scenario
        uiapp.visible = 1;
        root.NewScenario('Using_MATLAB_Automation');
        scenario = root.CurrentScenario;
    else
        %If a Scenario is open, prompt the user to accept closing it or not
        rtn = questdlg({'Close the current scenario?',' ','(WARNING: If you have not saved your progress will be lost)'});
        if ~strcmp(rtn,'Yes')
            return
        else
            root.CurrentScenario.Unload
            uiapp.visible = 1;
            root.NewScenario('Using_MATLAB_Automation');
            scenario = root.CurrentScenario;
        end
    end

catch
    % STK is not running, launch new instance
    % Launch a new instance of STK12 and grab it
    uiapp = actxserver('STK12.application');
    root = uiapp.Personality2;
    uiapp.visible = 1;
    root.NewScenario('Using_MATLAB_Automation');
    scenario = root.CurrentScenario;
end

toc
%% Get the path to the STK install directory
installDirectory = root.ExecuteCommand('GetDirectory / STKHome').Item(0);

%% This section will create the scenario
disp('* Creating scenario settings *')

%Sets our scenario's analytic and animation time period and resets the
%animation to the starting point
scenario.SetTimePeriod('24 Feb 2012 16:00:00.000','25 Feb 2012 16:00:00.000');
scenario.StartTime = '24 Feb 2012 16:00:00.000';
scenario.StopTime = '25 Feb 2012 16:00:00.000';
%Resets the animation to the start time
root.ExecuteCommand('Animate * Reset');
%Maximizes the 3D Graphics Window
root.ExecuteCommand('Window3D * Maximize');

%% This section will create a facility and geostationary satellite
disp('* Creating facility and geostationary satellite *')

%Instantiates new facility object named "GroundStation"
facility = scenario.Children.New('eFacility','GroundStation');
facility.Position.AssignGeodetic(36.1457,-114.5946,0);
satellite = scenario.Children.New('eSatellite','GeoSat');
keplerian = satellite.Propagator.InitialState.Representation.ConvertTo('eOrbitStateClassical'); % Use the Classical Element interface
keplerian.SizeShapeType = 'eSizeShapeAltitude';  % Changes from Ecc/Inc to Perigee/Apogee Altitude
keplerian.LocationType = 'eLocationTrueAnomaly'; % Makes sure True Anomaly is being used
keplerian.Orientation.AscNodeType = 'eAscNodeLAN'; % Use LAN instead of RAAN for data entry
% Assign the perigee and apogee altitude values:
keplerian.SizeShape.PerigeeAltitude = 35788.1;      % km
keplerian.SizeShape.ApogeeAltitude = 35788.1;       % km
% Assign the other desired orbital parameters:
keplerian.Orientation.Inclination = 0;         % deg
keplerian.Orientation.ArgOfPerigee = 0;        % deg
keplerian.Orientation.AscNode.Value = 245;       % deg
keplerian.Location.Value = 180;                 % deg
% Apply the changes made to the satellite's state and propagate:
satellite.Propagator.InitialState.Representation.Assign(keplerian);
satellite.Propagator.Propagate;

%% Creates a great arc propagated aircraft and adds waypoints to its route
disp('* Creating great arc aircraft *')

%Instantiates a default aircraft object named "Predator", and sets the 3D
%graphics model to the Predator UAV
aircraft = scenario.Children.New('eAircraft','Predator');
model = aircraft.VO.Model;
model.ModelData.Filename = 'STKData\VO\Models\Air\rq-1a_predator.mdl';
% Set route to great arc, method and altitude reference
aircraft.SetRouteType('ePropagatorGreatArc');
route = aircraft.Route;
route.Method = 'eDetermineTimeAccFromVel';
route.SetAltitudeRefType('eWayPtAltRefMSL');
% Add first point
waypoint = route.Waypoints.Add();
waypoint.Latitude = 46.098;
waypoint.Longitude = -122.0823;
waypoint.Altitude = 4.5;  % km
waypoint.Speed = .075;    % km/sec
% Add second point
waypoint2 = route.Waypoints.Add();
waypoint2.Latitude = 46.269;
waypoint2.Longitude = -122.192;
waypoint2.Altitude = 4.5; % km
waypoint2.Speed = .075;    % km/sec
waypoint2.TurnRadius = .25; % km
% Add third point
waypoint3 = route.Waypoints.Add();
waypoint3.Latitude = 46.251;
waypoint3.Longitude = -122.248;
waypoint3.Altitude = 4.5; % km
waypoint3.Speed = .075;    % km/sec
waypoint3.TurnRadius = .25; % km
% Add fourth point
waypoint4 = route.Waypoints.Add();
waypoint4.Latitude = 46.076;
waypoint4.Longitude = -122.131;
waypoint4.Altitude = 4.5; % km
waypoint4.Speed = .075;    % km/sec
%Propagate the route
route.Propagate;

%% Adds terrain and imagery to the scenario for analysis and realism
disp('* Adding terrain and imagery *')

%Instantiates the SceneManager object for use
manager = scenario.SceneManager;
%Adds Terrain in for analysis
root.ExecuteCommand(['Terrain * Add Type PDTT File "' installDirectory 'STKData\VO\Textures\St Helens.pdtt"']);
%Visually implements the terrain to our 3D Graphics
terrainTile = manager.Scenes.Item(0).CentralBodies.Earth.Terrain.AddUriString([installDirectory 'STKData\VO\Textures\St Helens.pdtt']);
terrain.UseTerrain = true;
%terrain
%Visually implements the imagery to our 3D Graphics
imageryTile = manager.Scenes.Item(0).CentralBodies.Earth.Imagery.AddUriString([installDirectory 'STKData\VO\Textures\St Helens.jp2']);
extentImagery = imageryTile.Extent;
disp(['Imagery boundaries: LatMin: ' num2str(extentImagery{1}) ' LatMax: ' num2str(extentImagery{3}) ' LonMin: ' num2str(extentImagery{2}) ' LonMax: ' num2str(extentImagery{4})]);
%Enables 3D Graphics Window label declutter
root.ExecuteCommand('VO * Declutter Enable On');

%% Sets the camera view
disp('* Setting the camera view *')

%Commands that view the "Normal" (bird's eye view) of the Mt St Helens
%imagery we loaded into the scenario and zooms out of the current view using 
%a value based on a fraction of the central body (Earth)
root.ExecuteCommand(['VO * ViewFromTo Normal From "' installDirectory 'STKData/VO/Textures/St Helens.jp2"']);
root.ExecuteCommand('VO * View Zoom WindowID 1 FractionofCB -0.0015');


%% Creates random targets with various properties, and stores their unconstrained access range data
%pro
disp('* Creating random targets and storing range data *')

%Generates pseudorandom latitude values of value "MasterTnum"
targetlocations_lat = 46.1991 - .035 + .07*rand(1,MasterTnum);
%Generates pseudorandom longitude values of value "MasterTnum"
targetlocations_long = -122.1864 - .035 + .07*rand(1,MasterTnum); 
%Creates a constellation in anticipation of the for loop which will
%populate it. This constellation will be used in the chain acces computation.
constellation = root.CurrentScenario.Children.New('eConstellation','TargetGroup');
%Instantiates five targets using the respective pseudorandom lat/long values
%and enables terrain altitude data use, in addition to creating visible
%AzElMasks and using them as constraints. Also populates our constellation object.
for i = 1:MasterTnum
    tname = ['Target' num2str(i)];
    target(i) = scenario.Children.New('eTarget',tname);
    target(i).Position.AssignGeodetic(targetlocations_lat(1,i),targetlocations_long(1,i),0);
    target(i).UseTerrain = true;
    target(i).SetAzElMask('eTerrainData',0);
    target(i).Graphics.LabelVisible = false;
    azelMask(i) = target(i).Graphics.AzElMask;
    azelMask(i).RangeVisible = false;
    %azelMask(i).NumberOfRangeSteps = 10;
    %azelMask(i).DisplayRangeMinimum = 0;   % km
    %azelMask(i).DisplayRangeMaximum = 1;  % km
    %azelMask(i).RangeColorVisible = true;
    %azelMask(i).RangeColor = 16776960; % cyan
    %root.ExecuteCommand(['VO */Target/' tname ' AzElMask ShowCompassLabels Off']);
    constellation.Objects.AddObject(target(i));
end
%Computes access for the aircraft to each target
for r = 1:MasterTnum
    Taccess(r) = aircraft.GetAccessToObject(target(r));
    Taccess(r).ComputeAccess;
end
%Sets units of time to Epoch Seconds so our time step input and start and stop
%times are in seconds.
root.UnitPreferences.Item('DateFormat').SetCurrentUnit('EpSec');
%Computes unconstrained access for all targets and retrieves range data and
%start and stop times of access
for i = 1:MasterTnum
    TaccessDP1_0test = Taccess(i).DataProviders.Item('Access Data').Exec(scenario.StartTime,scenario.StopTime);
    %disp(TaccessDP1_0test.DataSets.GetDataSetByName('Start Time').GetValues)
    TaccessStart{i} = TaccessDP1_0test.DataSets.GetDataSetByName('Start Time').GetValues;
    TaccessStop{i} = TaccessDP1_0test.DataSets.GetDataSetByName('Stop Time').GetValues;
    TPosDP(i) = Taccess(i).DataProviders.Item('AER Data').Group.Item('Default').Exec(cell2mat(TaccessStart{i}),cell2mat(TaccessStop{i}),2);
    Trange{i} = cell2mat(TPosDP(i).DataSets.GetDataSetByName('Range').GetValues);
end
%Clears all access - active access is no longer neccessary as we've stored these values
root.ExecuteCommand('ClearAllAccess /');
%Enables the AzElMask access constraint
for i = 1:MasterTnum
    tname = ['Target' num2str(i)];
    root.ExecuteCommand(['SetConstraint */Target/' tname ' AzElMask On']);
end

%% Extracts LLA/cartesian position data for the aircraft and targets. Finds out which target is closest and if it has access at any given time.
disp('* Finding which Targets are closest to Aircraft per given time step *')

%Sets units of time to UTCG so we can use the time strings from the data
%provider to tell the sensor when to point
root.UnitPreferences.Item('DateFormat').SetCurrentUnit('UTCG');
%Extracts the from the data provider "LLA State" the "Fixed" folder items
aircraftPosDP = aircraft.DataProviders.Item('LLA State').Group.Item('Fixed').Exec(scenario.StartTime,scenario.StopTime,2);
%Extracts Latitude, Longitude and Altitude for the aircraft
aircraftLat = cell2mat(aircraftPosDP.DataSets.GetDataSetByName('Lat').GetValues);
aircraftLon = cell2mat(aircraftPosDP.DataSets.GetDataSetByName('Lon').GetValues);
aircraftAlt = cell2mat(aircraftPosDP.DataSets.GetDataSetByName('Alt').GetValues);
aircraftTime = cell2mat(aircraftPosDP.DataSets.GetDataSetByName('Time').GetValues);
%Sets units of time back to Epoch Seconds
root.UnitPreferences.Item('DateFormat').SetCurrentUnit('EpSec');
%Extracts x,y and z cartesian positions for the aircraft for use in our
%custom range/distance calculation.
aircraftCartDP = aircraft.DataProviders.Item('Cartesian Position').Group.Item('Fixed').Exec(scenario.StartTime,scenario.StopTime,2);
aircraftX = cell2mat(aircraftCartDP.DataSets.GetDataSetByName('x').GetValues);
aircraftY = cell2mat(aircraftCartDP.DataSets.GetDataSetByName('y').GetValues);
aircraftZ = cell2mat(aircraftCartDP.DataSets.GetDataSetByName('z').GetValues);
%Below is a similar but time independant version of the cartesian coordinate
%data provider set for the targets
for g = 1:MasterTnum
    alltargetPosDP{g} = target(g).DataProviders.Item('Cartesian Position').Exec;
    alltargetX(g,1) = cell2mat(alltargetPosDP{g}.DataSets.GetDataSetByName('x').GetValues);
    alltargetY(g,1) = cell2mat(alltargetPosDP{g}.DataSets.GetDataSetByName('y').GetValues);
    alltargetZ(g,1) = cell2mat(alltargetPosDP{g}.DataSets.GetDataSetByName('z').GetValues);
end
%Computes access for the aircraft to each target
for r = 1:MasterTnum
    Taccess(r) = aircraft.GetAccessToObject(target(r));
    Taccess(r).ComputeAccess;
end
%Retrieves and stores access start and stop time data for each target
for r = 1:MasterTnum
    allTaccessDP{r} = Taccess(r).DataProviders.Item('Access Data').Exec(scenario.StartTime,scenario.StopTime);
    allTaccessStart{r} = allTaccessDP{r}.DataSets.GetDataSetByName('Start Time').GetValues;
    allTaccessStop{r} = allTaccessDP{r}.DataSets.GetDataSetByName('Stop Time').GetValues;
    %Finds the number of elements for the access time logs of each target
    num(r,1) = numel(allTaccessStart{r});
end
%Clears all access - active access is no longer neccessary as we've stored those values
root.ExecuteCommand('ClearAllAccess /');
%Initializes timecount as a counter for epoch seconds passed in our custom logic code.
timecount = 0;
%This for loop creates "MasterTnum" # of arrays which store true and false values for whether or not 
%any given target has access to the aircraft at any given time in steps of 2 epoch seconds
for g = 1:300
    for q = 1:MasterTnum
        for k = 1:num(q,1)
            if timecount>=cell2mat(allTaccessStart{q}(k,1)) && timecount<=cell2mat(allTaccessStop{q}(k,1))
                YesNo{q}(g,1) = 1;
                break
            elseif k ~= num(1,1)
                %do nothing
            else
                YesNo{q}(g,1) = 0;
            end
        end
    end
    timecount = timecount + 2;
end
%The for loop below calculates the distance(range) from the aircraft to
%each given target at any time in steps of 2 epoch seconds. After, it finds
%which of those distances at any given time is the smallest. Then, it
%checks which target that smallest distance corresponds to and finds out
%whether or not the aircraft has access to that target at that given time -
%if it has access an array will store the corresponding number of that
%target, and if it does not have access the array will store a 0(false).
for n = 1:300
    for j = 1:MasterTnum
        alltargetdist{j}(n,1) = sqrt((alltargetX(j,1)-aircraftX(n,1))^2 + (alltargetY(j,1)-aircraftY(n,1))^2 + (alltargetZ(j,1)-aircraftZ(n,1))^2);
        checkdist(j,1) = alltargetdist{j}(n,1);
    end
    check = min(checkdist);

    %try
        for v = 1:MasterTnum   
            if checkdist(v,1) == check
                if YesNo{v}(n,1) == 1 
                    targetmin(n,1) = v;
                else
                    targetmin(n,1) = 0;
                end
            end
        end
    %catch
    %    errordlg('Try re-running the script.','Improper Time Interval Indexing');
    %    return
    %end
end 

%% Creates a sensor and populates it with a pointing queue that allows it to point to the closest target if it has access to it
disp('* Creating a sensor and pointing to closest Targets *')

%Add a sensor to the main aircraft
sensor = aircraft.Children.New('eSensor', 'Targeted');
pattern1 = sensor.Pattern;
pattern1.ConeAngle = 5;
sensor.SetPointingType('eSnPtTargeted');
%Initially adding in all of the target objects to the sensor pointing queue.
%All of these values will require overriding for the code to function properly.
pointing1 = sensor.Pointing;
 for t = 1:MasterTnum
    pointing1.Targets.AddObject(target(t));
    ttrue(t,1) = 1;
end

%This for loop checks which target is closest and if it has
%access, and based on the criteria adds it to the sensor pointing queue for
%a span of two seconds, at a two second step interval.
%If the closest target does not have access (ie the array returns 0) then it will do nothing,
%effectively turning off the sensor until a closest target has access again.
for m = 1:300
    for k = 1:MasterTnum
        if targetmin(m,1) == k
            targnum = num2str(k);
            if ttrue(k,1) == 0
                root.ExecuteCommand(['Point */Aircraft/Predator/Sensor/Targeted Targeted Times Add Target/Target' targnum ' "' aircraftTime(m,:) '" "' aircraftTime(m+1,:) '" ']);
            else
                root.ExecuteCommand(['Point */Aircraft/Predator/Sensor/Targeted Targeted Times Replace Target/Target' targnum ' 1 "' aircraftTime(m,:) '" "' aircraftTime(m+1,:) '" ']);
                ttrue(k,1)=0;
            end
        end
    end
end
%Remove targets not being pointed at from the sensor pointing queue
pointing1 = sensor.Pointing;
try

    for i = MasterTnum:-1:1
        if ttrue(i,1) == 1
            %disp(i)
            pointing1.Targets.RemoveObject(target(i));
        end
    end

catch
    errordlg('Try re-running the script.','Improper IAgSnTarget Indexing');
    return
end
    
%% Computes access and retrieves data providers for the facility and satellite
disp('* Computing access and retrieving data providers *')

%Computes access between the satellite and the facility
access = satellite.GetAccessToObject(facility);
access.ComputeAccess;
%Retrieves the access data for interval start/stop times
accessDP = access.DataProviders.Item('Access Data').Exec(scenario.StartTime,scenario.StopTime);
accessStartTimes = accessDP.DataSets.GetDataSetByName('Start Time').GetValues;
accessStopTimes = accessDP.DataSets.GetDataSetByName('Stop Time').GetValues;
%Retrieves the altitude data for the satellite during access
satelliteDP = satellite.DataProviders.Item('LLA State').Group.Item('Fixed').ExecElements(accessStartTimes{1},accessStopTimes{1},60,{'Time';'Alt'});
%Displays the altitude values
satellitealtitude = satelliteDP.DataSets.GetDataSetByName('Alt').GetValues;

%% Creates a populates a chain connecting the information network of the mission. 
%* It then plots range data as well as which target is being accessed by the sensor at any given time.
disp('* Creating chain and plotting range information *')

%Instantiates a new chain and adds the objects involved with the
%information transfer that occurs in this scenario
chain = scenario.Children.New('eChain', 'SensorInfoNetwork');
chain.Objects.AddObject(constellation);
chain.Objects.AddObject(sensor);
chain.Objects.AddObject(aircraft);
chain.Objects.AddObject(satellite);
chain.Objects.AddObject(facility);
%Computes access for the chain, allowing us to analyze and see when and how
%this chain is connected
chain.ComputeAccess();

%The code below retrieves the Data Provider information for the chain
%access and specifically writes the Data Providers for Range and
%corresponding Time to cell arrays.
TChainAER1 = chain.DataProviders.Item('Access AER Data').Exec(cell2mat(TaccessStart{1}),cell2mat(TaccessStop{1}),2);
sectionnum = TChainAER1.Intervals.Count;
for q = 1:sectionnum
    TChainrange{q} = TChainAER1.Intervals.Item(q-1).DataSets.GetDataSetByName('Range').GetValues;
    TChaintime{q} = TChainAER1.Intervals.Item(q-1).DataSets.GetDataSetByName('Time').GetValues;
end

%This sequence of code checks the Data Provider information stored in the
%cell arrays and "filters out" or discludes the writing into another array
%the GeoSat and GroundStation access information, only re-storing the
%sensor-to-target access data and corresponding times for later use.
hurdleflag = 0; %counter variable for target number
hurdlecheck = 0; %switch for first entry of each target
genericcounter = 0; %counter for number of individual accesses
for q = 1:sectionnum
    tempchainrange = cell2mat(TChainrange{q});
    tempchaintime = cell2mat(TChaintime{q});
    if tempchainrange(1) < 1000 %removing GeoSat ranges
        genericcounter = genericcounter + 1;
        chainrangeArray{genericcounter} = tempchainrange;
        chaintimeArray{genericcounter} = tempchaintime;
        if hurdlecheck == 0
            hurdlecheck = 1;
            hurdleflag = hurdleflag + 1;
            whichtarget(genericcounter) = hurdleflag;
        else
            whichtarget(genericcounter) = hurdleflag;
        end
    else
        hurdlecheck = 0;
    end
end

%Instantiates some flag variables for later use
noteq = 1;
for h = 1:MasterTnum
    almosteq(h,1) = 0;
end
%Creates an independent time array based on the length of the range array lengths
for f = 1:MasterTnum
    endtime(f,1) = numel(Trange{f});
    indie_time{f} = cell2mat(TaccessStart{1}):2:cell2mat(TaccessStop{1});
    interval(f,1) = numel(indie_time{f});
end

%truncates mismatching array indeces
while noteq == 1
    for m = 1:MasterTnum
        if endtime(m,1) ~= interval(m)
            Trange{m}(end) = [];
            endtime(m,1) = numel(Trange{m});
        else 
            almosteq(m,1) = 1;
        end
    end
    %sees if every target has been checked
    bool = true;
    for i = 1:MasterTnum
        bool = bool && (almosteq(i,1) == 1);
    end 
    if bool
        noteq = 0;
    end
end
%Finds the minimum range of each target and stores the index of that element
for n = 1:MasterTnum
    [minrange(n),rangeloc(n)] = min(Trange{n});
end
closestapp = min(minrange);
%Creates a figure and begins to plot and label it in a variety of ways
figure;
endtime(1,1) = numel(Trange{1});
interval1 = numel(indie_time{1});
colors = ['b'; 'g'; 'r'; 'k'; 'm'; 'y'; 'c'];
colorcount = 1;
startplot = 1;
for n = 1:MasterTnum
    if startplot ~=1
        plot(indie_time{n},Trange{n},colors(colorcount),'linewidth',1);
    elseif startplot == 1
        plot(indie_time{1},Trange{1},'linewidth',1);
        xlabel('Time Since Flyby Start(epoch seconds)') ;
        ylabel('Range (km)');
        title('Sensor Access Closest Approach Visual');
        hold on
        startplot = 0;
    end
    colorarray(n) = colors(colorcount);
    if colorcount == 7
        colorcount = 0;
    end
    colorcount = colorcount + 1;
end
%Checks which target is being pointed to so the access plots use the correct colors
for b = 1:genericcounter
    modi = colorarray(whichtarget(b));
    plot(chaintimeArray{b},chainrangeArray{b}, [modi '--'],'linewidth',3);
end
%Plots a circle for the minimum range the aircraft reaches with any target
for m = 1:MasterTnum
    if closestapp == minrange(m);
        closesttimeloc = rangeloc(m);
        plot(indie_time{m}(closesttimeloc),closestapp,'o','linewidth',2);
    end
    legendstr{m} = ['Target ', num2str(m)];
end
legend(legendstr);
hold off

%%
%Animates the scenario
disp('* Changing the animation settings *')

%This Connect code simply gives the animation a start time, stop time and time step
root.ExecuteCommand('SetAnimation * StartAndCurrentTime "24 Feb 2012 16:00:00.00" EndTime "24 Feb 2012 16:10:00.00" TimeStep 0.5');
