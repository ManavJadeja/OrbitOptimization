%% Setup and create the scenario
% This script walks through the basic functions of the STK Aviator Object
% Model by flying a route from JFK to LAX at various altitudes and
% comparing the fuel consumption. The tutorial also makes use of the
% Advanced Fixed Wing Tool by creating an aircraft performance model that
% uses a high bypass turbofan engine.

try
    % Grab an existing instance of STK
    uiapp = actxGetRunningServer('STK12.application');
    %Attach to the STK Object Model
    root = uiapp.Personality2;
    checkempty = root.Children.Count;
    if checkempty == 0
        %If a Scenario is not open, create a new scenario
        uiapp.visible = 1;
        root.NewScenario('AviatorParametricDemo');
        scenario = root.CurrentScenario;
    else
        %If a Scenario is open, prompt the user to accept closing it or not
        rtn = questdlg({'Close the current scenario?',' ','(WARNING: If you have not saved your progress will be lost)'});
        if ~strcmp(rtn,'Yes')
            return
        else
            root.CurrentScenario.Unload
            uiapp.visible = 1;
            root.NewScenario('AviatorParametricDemo');
            scenario = root.CurrentScenario;
        end
    end

catch
    % STK is not running, launch new instance
    % Launch a new instance of STK12 and grab it
    uiapp = actxserver('STK12.application');
    root = uiapp.Personality2;
    uiapp.visible = 1;
    root.NewScenario('AviatorParametricDemo');
    scenario = root.CurrentScenario;
end

% Set the date format
root.UnitPreferences.SetCurrentUnit('DateFormat', 'EpHr');
% Create an aircraft
aircraft = root.CurrentScenario.Children.New('eAircraft', 'Aircraft');


%% Set the propagator to Aviator and get the mission items

% Set the Aviator Propagator
aircraft.SetRouteType('ePropagatorAviator');

% Grab the Aviator Propagator
avtrProp = aircraft.Route.AvtrPropagator;

% Grab the mission
avtrMission = avtrProp.AvtrMission;
% From the mission grab the phase collection
phases = avtrMission.Phases;
% Get the first phase
phase = phases.Item(0);
% Get the procedure collection
procedures = phase.Procedures

%%  Get the runways from the catalog

% Get the runway category
runwayCategory = avtrProp.AvtrCatalog.RunwayCategory
% Set the ARINC runways to look at the installed sample
runwayCategory.ARINC424Runways.MasterDataFilepath = 'C:\Program Files\AGI\STK 12\Data\Resources\stktraining\samples\FAANFD18'
% Get the list of runways
runwayList = runwayCategory.ARINC424Runways.ChildNames;
% Save JFK
JFK = runwayCategory.ARINC424Runways.GetARINC424Item('JOHN F KENNEDY INTL 04L 22R');
% Save LAX
LAX = runwayCategory.ARINC424Runways.GetARINC424Item('LOS ANGELES INTL 06L 24R');

%% We will now create an Advanced Airliner model using the Advanced Fixed
% Wing Tool and set some representative parameters

% Get the aircraft category
ac = avtrProp.AvtrCatalog.AircraftCategory
% If there is already an aircraft with the same name, delete it
if ac.AircraftModels.Contains('Advanced Airliner') > 0
    ac.AircraftModels.RemoveChild('Advanced Airliner')
end

% Change the aircraft
basicAirliner = ac.AircraftModels.GetAircraft('Basic Airliner');
% Make a copy
advAirliner = basicAirliner.Duplicate;
% Rename
advAirliner.Name = 'Advanced Airliner'
% Get the advanced fixed wing tool
advTool = advAirliner.AdvFixedWingTool;
% Set the max mach number
advTool.MaxMach = 0.88;
% Want to use subsonic aerodynamics
advTool.AeroStrategy = 'eSubsonicAero'
% And a high bypass turbofan
advTool.PowerplantStrategy = 'eTurbofanHighBypass';
% Get the engine
engine = advTool.PowerplantModeAsEmpiricalJetEngine
% Thrust of 200,000 lbf
engine.MaxSeaLevelStaticThrust = 200000;
% Set the design point alt
engine.DesignPointAltitude = 39000;
% Create the performance models, overwrite any previous ones, and set them
% as default
advTool.CreateAllPerfModels('AdvancedModel', 1, 1);

% Now set the airliner
avtrMission.Vehicle = advAirliner;

%% Add a takeoff procedure

% Add a takeoff procedure from a runway
takeoff = procedures.Add('eSiteRunway','eProcTakeoff')
% Get the site
jfkRunway = takeoff.Site;
% Copy the JFK runway
jfkRunway.CopyFromCatalog(JFK);

%% Add an enroute procedure

enroute = procedures.Add('eSiteRunway','eProcEnroute')
%Fly to LAX
% Set the runway
laxRunway = enroute.Site;
% Copy the LAX runway
laxRunway.CopyFromCatalog(LAX)
% Change the heading if you have some specific info different from the
% catalog
laxRunway.LowEndHeading = 35;
% Now rename and save this runway to use for the next procedure
laxRunway.Name = 'LAX Alternate Runway';
% Takes in argument of whether to overwrite any user runway with the same
% name
laxRunway.AddToCatalog(1)
% Don't use the default cruise altitude
enroute.AltitudeMSLOptions.UseDefaultCruiseAltitude = 0;

%% Add the landing procedure

landing = procedures.Add('eSiteRunway', 'eProcLanding')
% Set the name of the procedure
landing.Name = 'Landing';

% Set the runway
landingRunway = landing.Site;
% Use the runway you just added to the catalog
laxAlternate = runwayCategory.UserRunways.GetUserRunway('LAX Alternate Runway')
landingRunway.CopyFromCatalog(laxAlternate);

%% Set the initial altitudes

% Altitudes to fly
altitudes = 20000:5000:45000;
totalFuel = zeros(1,6);
totalTime = zeros(1,6);

%% Iterate over each altitude and get the fuel consumed and time of flight
for i = 1:6
    % Set the altitude of the route
    'Setting altitude to ' + string(altitudes(i)) + ' ft'
    enroute.AltitudeMSLOptions.MSLAltitude = altitudes(i);
    % Re-propagate
    avtrProp.Propagate
    % Recalculate the report
    flightDP = aircraft.DataProviders.Item('Flight Profile By Time').Exec(4.5, 6.5, 3600);
    % Get the fuel used
    fuelUsed = cell2mat(flightDP.DataSets.GetDataSetByName('Fuel Consumed').GetValues);
    % Save the total fuel consumed
    totalFuel(i) = fuelUsed(size(fuelUsed, 1));
    % Get the time
    time = cell2mat(flightDP.DataSets.GetDataSetByName('Time').GetValues);
    % Save the total duration of the flight
    totalTime(i) = time(size(time, 1));
end

%% Plot Results

close all

figure;
plot(altitudes, totalFuel)
xlabel('Altitude (ft)')
ylabel('Fuel Consumed (lb)')
title('Fuel Consumed at Each Altitude')
ax = gca;
ax.XRuler.Exponent = 0;
ax.YRuler.Exponent = 0;
grid on

figure;
plot(altitudes, totalTime)
xlabel('Altitude (ft)')
ylabel('Time of Flight (Hours)')
title('Total Time of Flight at Each Altitude')
ax = gca;
ax.XRuler.Exponent = 0;
ax.YRuler.Exponent = 0;
grid on

figure;
plot3(altitudes, totalTime, totalFuel)
xlabel('Altitude (ft)')
ylabel('Time of Flight (Hours)')
zlabel('Fuel Consumed (lb)')
title('Fuel Consumed and Time of Flight at Varying Altitudes')
ax = gca;
ax.XRuler.Exponent = 0;
ax.YRuler.Exponent = 0;
grid on