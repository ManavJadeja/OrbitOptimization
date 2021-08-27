clear, clc

%%% Quick tip: If you would like to use a more detailed carrier ship
%%% download the CVN-72 model from support.agi.com/3d-models and
%%% place it into the following location before running the script: 
%%% <STK Install Directory>\STKData\VO\Models\Sea

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setup and Create the Scenario
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create a waitbar figure
f = waitbar(0,'                                           Opening the application                                           '); % leave whitespaces as they help set size

try
    % Grab an existing instance of STK
    stkUiApplication = actxGetRunningServer('STK12.application');
    stkRoot = stkUiApplication.Personality2;
    checkempty = stkRoot.Children.Count;
    if checkempty == 0
        %If a Scenario is not open, create a new scenario
        stkUiApplication.Visible = 1;
        stkRoot.NewScenario('Aviator_Carrier_Landing_Example');
    else
        %If a Scenario is open, prompt the user to accept closing it or not
        rtn = questdlg({'Close the current scenario?',' ','(WARNING: If you have not saved, your progress will be lost)'});
        if ~strcmp(rtn,'Yes')
            return
        else
            stkRoot.CurrentScenario.Unload;
            stkUiApplication.Visible = 1;
            stkRoot.NewScenario('Aviator_Carrier_Landing_Example');
        end
    end
catch
    % STK is not running, launch new instance of STK 12 and grab it
    stkUiApplication = actxserver('STK12.application');
    stkUiApplication.Visible = 1;
    stkRoot = stkUiApplication.Personality2;
    stkRoot.NewScenario('Aviator_Carrier_Landing_Example');
end
tic
% Update waitbar
waitbar(.10,f,'Creating new scenario');

% Set scenario time interval
scenario = stkRoot.CurrentScenario;
scenario.SetTimePeriod('20 Jan 2020 17:00:00.000', '+2 hours'); % times are UTCG
% Reset animation time to new scenario start time
stkRoot.Rewind;

% Set scenario global reference to MSL
scenario.VO.SurfaceReference = 'eMeanSeaLevel';

% Maximize application window
stkRoot.ExecuteCommand('Application / Raise');
stkRoot.ExecuteCommand('Application / Maximize');

% Maximize 3D window
stkRoot.ExecuteCommand('Window3D * Maximize');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create Facility to Represent the Oceana Naval Air Station (KNTU)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Update waitbar
waitbar(.15,f,'Adding Oceana Naval Air Station');

facilityKntu = scenario.Children.New('eFacility','OCEANA_NAS__APOLLO_SOUCEK_FIELD');

% Set facility postiion
facilityKntu.UseTerrain = true;
facilityKntu.Position.AssignGeodetic(36.822744, -76.031892, 0.0); % setting alt to zero will place it on terrain

% Set facility color
facilityKntu.Graphics.Color = 16777215; % white

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create Ship to Represent the USS Abraham Lincoln (CVN-72)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Update waitbar
waitbar(.20,f,'Adding CVN-72 carrier ship');

shipCvn72 = scenario.Children.New('eShip','CVN-72');

% Set route properties
shipCvn72.SetRouteType('ePropagatorGreatArc');
shipCvn72.Route.SetAltitudeRefType('eWayPtAltRefTerrain');
shipCvn72.Route.AltitudeRef.Granularity = 1; % km

% Set waypoints
waypoint1 = shipCvn72.Route.Waypoints.Add();
waypoint1.Latitude = 36.64988281; % deg
waypoint1.Longitude = -75.11230361; % deg
waypoint1.Speed = 0.01543333; % km/s
waypoint1.Altitude = 0; % km
waypoint2 = shipCvn72.Route.Waypoints.Add();
waypoint2.Latitude = 36.63713768; % deg
waypoint2.Longitude = -74.87339587; % deg
waypoint2.Speed = 0.01543333; % km/s
waypoint2.Altitude = 0; % km
waypoint3 = shipCvn72.Route.Waypoints.Add();
waypoint3.Latitude = 36.65454874; % deg
waypoint3.Longitude = -75.29117133; % deg
waypoint3.Speed = 0.01543333; % km/s
waypoint3.Altitude = 0; % km

% Set display properties
shipCvn72.Graphics.Attributes.Color = 16776960; % cyan
shipCvn72.Graphics.Attributes.Line.Width = 'e3'; % medium thickness

% Set ship model
try
    % Insert CVN-72 model if user has added to the STK install folder
    shipCvn72.VO.Model.ModelData.Filename = 'STKData\VO\Models\Sea\cvn-72\cvn-72.mdl';
catch
    % Insert default carrier model from STK install folder
    shipCvn72.VO.Model.ModelData.Filename = 'STKData\VO\Models\Sea\aircraft-carrier.mdl';
    shipCvn72.VO.Offsets.Translational.Enable = true;
    shipCvn72.VO.Offsets.Translational.Z = 0.02; % km
end

% Propagate ship
shipCvn72.Route.Propagate();

% Position 3D window near ship
stkRoot.ExecuteCommand('VO * ViewFromTo Normal From Ship/CVN-72'); % zoom to ship
stkRoot.ExecuteCommand('VO * ViewerPosition 20 115 150000'); % set view position

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create Lead Hornet Aircraft to Perform Carrier Landing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Update waitbar
waitbar(.25,f,'Creating lead hornet aircraft');

aircraftHornetLead = scenario.Children.New('eAircraft','Hornet_Flight_Lead');

% Set propagator to Aviator
aircraftHornetLead.SetRouteType('ePropagatorAviator');

% Grab the Aviator Propagator
avtrPropHornetLead = aircraftHornetLead.Route.AvtrPropagator;

% Grab the Aviator catalog. This handle can be used for later aircraft too.
catalog = avtrPropHornetLead.AvtrCatalog;

% Grab the aircraft models from the catalog
acModels = catalog.AircraftCategory.AircraftModels;

% If a copy of the Basic Fighter aircraft model already exists, remove it
if acModels.Contains('Basic Fighter')
    basicFighter = acModels.GetAircraft('Basic Fighter');
else
    disp('Basic Fighter aircraft model cannot be found.');
end

% Grab the mission
avtrMissionHornetLead = avtrPropHornetLead.AvtrMission;

% Set the aircraft model to Basic Fighter Copy
avtrMissionHornetLead.Vehicle = basicFighter;

% From the mission grab the phase collection
phasesHornetLead = avtrMissionHornetLead.Phases;

% Get the first phase
phaseHornetLead = phasesHornetLead.Item(0);

% Get the procedure collection
proceduresHornetLead = phaseHornetLead.Procedures;

% Set display properties
aircraftHornetLead.Graphics.Attributes.Color = 65535; % yellow
aircraftHornetLead.Graphics.Attributes.Line.Width = 'e3'; % medium thickness

%%  Get the runways from the catalog

% Get the runway category
runwayCategory = avtrPropHornetLead.AvtrCatalog.RunwayCategory;

% Set the ARINC runways to look at the installed sample
installDir = stkRoot.ExecuteCommand('GetDirectory / STKHome').Item(0);
runwayCategory.ARINC424Runways.MasterDataFilepath = strcat(installDir,'Data\Resources\stktraining\samples\FAANFD18');

% Get the list of runways
runwaysARINC424 = runwayCategory.ARINC424Runways;
runwayList = runwaysARINC424.ChildNames;

% Grab Oceana NAS from runways
runwayNameOceana = 'OCEANA NAS /APOLLO SOUCEK FIEL 05R 23L';
if runwaysARINC424.Contains(runwayNameOceana)
    oceana = runwaysARINC424.GetARINC424Item(runwayNameOceana);
else
    disp(['Runway "', runwayNameOceana, '" does not exist in catalog.'])
end

%% Add a Takeoff Procedure

% Update waitbar
waitbar(.30,f,'Lead hornet - adding takeoff procedure');

% Add a takeoff procedure from a runway
takeoffHornetLead = proceduresHornetLead.Add('eSiteRunway','eProcTakeoff');

%%% Quick tip: You can use the MATLAB invoke method to quickly see all of
%%% the available methods that can be used for a given handle. Try typing
%%% proceduresHornetLead.invoke into the MATLAB command window and hitting Enter.
%%% You can now see all of the possible methods which can be called from the
%%% proceduresB1 handle. You will also see the inputs and outputs for each
%%% method. Note that not every handle will support this method.

%%% Set the site properties

% Get the site
oceanaRunway = takeoffHornetLead.Site;

% Copy the Oceana runway
oceanaRunway.CopyFromCatalog(oceana);
oceanaRunway.Name = runwayNameOceana;

%%% Quick tip: You can use the MATLAB get method to quickly see all of the
%%% properties and their current values for a given handle. Try typing
%%% oceanaRunway.get or get(oceanaRunway) into the MATLAB command window and hitting
%%% Enter. You can see all of the properties that exist on the runway
%%% handle as well as their current values. Note that not every handle will
%%% support this method.

%%% Set the procedure properties

% Get the runway heading options
runwayOptionsHornetLead = takeoffHornetLead.RunwayHeadingOptions;

% Set it to low end
runwayOptionsHornetLead.RunwayMode = 'eLowEnd';

%%% Quick tip: You can discover all the possible enumerations for
%%% RunwayMode by typing "runwayOptionsHornetLead.RunwayMode = " in the Command
%%% Window and then hitting the Tab key. You can do this for any property
%%% that is an enumeration (not methods). Note however that in MATLAB you
%%% must pass the enumeration while surrounded by apostrophes, not
%%% quotations.

% Set the takeoff to normal
takeoffHornetLead.TakeoffMode = 'eTakeoffNormal';

% Get the interface for a normal takeoff
normalTakeoffHornetLead = takeoffHornetLead.ModeAsNormal;

% Get the angle and terrain option
normalTakeoffHornetLead.TakeoffClimbAngle = 3; % deg
normalTakeoffHornetLead.DepartureAltitude = 500; % ft
normalTakeoffHornetLead.RunwayAltitudeOffset = 0; % ft
normalTakeoffHornetLead.UseRunwayTerrain = true;

%% Add an Enroute Procedure to Begin Approach to Ship

% Update waitbar
waitbar(.35,f,'Lead hornet - adding enroute procedure to approach ship');

enrouteHornetLead = proceduresHornetLead.Add('eSiteStkObjectWaypoint','eProcEnroute');

%%% Set the site properties
enrouteHornetLeadSite = enrouteHornetLead.Site;

% Link to ship object
enrouteHornetLeadSite.ObjectName = 'Ship/CVN-72';

% Set waypoint time to scenario start time
enrouteHornetLeadSite.WaypointTime = scenario.StartTime;

% Set Offset mode and bearing/range values
enrouteHornetLeadSite.OffsetMode = 'eOffsetRelativeBearingRange';
enrouteHornetLeadSite.Bearing = 180; % deg
enrouteHornetLeadSite.Range = 40; % nm

%%% Set the procedure properties

% Set the altitude options
enrouteHornetLead.AltitudeMSLOptions.UseDefaultCruiseAltitude = false;
enrouteHornetLead.AltitudeMSLOptions.MSLAltitude = 20000; % ft

% Set the navigation options
enrouteHornetLead.NavigationOptions.NavMode = 'eArriveOnCourse';
enrouteHornetLead.NavigationOptions.ArriveOnCourse = 135; % deg

%% Add a 2nd Enroute Procedure to "Enter the Stack"

% Update waitbar
waitbar(.40,f,'Lead hornet - adding enroute procedure to enter stack');

enroute2HornetLead = proceduresHornetLead.Add('eSiteStkObjectWaypoint','eProcEnroute');

%%% Set the site properties
enroute2HornetLeadSite = enroute2HornetLead.Site;

% Link to ship object
enroute2HornetLeadSite.ObjectName = 'Ship/CVN-72';

% Set waypoint time to scenario start time
enroute2HornetLeadSite.WaypointTime = '20 Jan 2020 17:09:06.858'; % UTCG

% Set Offset mode and bearing/range values
enroute2HornetLeadSite.OffsetMode = 'eOffsetRelativeBearingRange';
enroute2HornetLeadSite.Bearing = 180; % deg
enroute2HornetLeadSite.Range = 10; % nm

%%% Set the procedure properties

% Set the procedure name
enroute2HornetLead.Name = 'Enter the Stack';

% Set the altitude options
enroute2HornetLead.AltitudeMSLOptions.UseDefaultCruiseAltitude = false;
enroute2HornetLead.AltitudeMSLOptions.MSLAltitude = 10000; % ft

% Set the navigation options
enroute2HornetLead.NavigationOptions.NavMode = 'eArriveOnCourseForNext';

% Set the enroute cruise airspeed options
enroute2HornetLead.EnrouteCruiseAirspeedOptions.CruiseSpeedType = 'eMaxEnduranceAirspeed';

%% Create a New Mission Phase for StationKeeping

phase2HornetLead = avtrMissionHornetLead.Phases.Add();
phase2HornetLead.Name = 'StationKeeping';

% Get procedures for new phase
procedures2HornetLead = phase2HornetLead.Procedures;

%% Add a Basic Maneuver Procedure to "Enter Case 1 Marshall"

% Update waitbar
waitbar(.45,f,'Lead hornet - adding maneuever to enter Case I Marshall');

% Add a Basic Maneuver procedure from the end of the previous procedure
basicManeuverHornetLead = procedures2HornetLead.Add('eSiteEndOfPrevProcedure','eProcBasicManeuver');

%%% Set the procedure properties

% Set procedure name
basicManeuverHornetLead.Name = 'Case I Marshall';

%%% Set the horizontal/navigation strategy
basicManeuverHornetLead.NavigationStrategyType = 'Stationkeeping';

% Get the navigation interface
stationkeepingNavHornetLead = basicManeuverHornetLead.Navigation;

% Set stationkeeping target
stationkeepingNavHornetLead.TargetName = 'Ship/CVN-72';

% Set station options
stationkeepingNavHornetLead.RelBearing = -90; % deg
stationkeepingNavHornetLead.RelRange = 2.7; % nm
stationkeepingNavHornetLead.DesiredRadius = 2.5; % nm
stationkeepingNavHornetLead.TurnDirection = 'eTurnLeft';

% Set stop condition options
stationkeepingNavHornetLead.StopCondition = 'eStopAfterTurnCount';
stationkeepingNavHornetLead.StopAfterTurnCount = 5;
stationkeepingNavHornetLead.UseRelativeCourse = true;
stationkeepingNavHornetLead.StopCourse = -180; % deg

%%% Set the vertical/profile strategy
basicManeuverHornetLead.ProfileStrategyType = 'Autopilot - Vertical Plane';

% Get the profile interface
autoProfileHornetLead = basicManeuverHornetLead.Profile;

% Set the altitude options
autoProfileHornetLead.AltitudeMode = 'eAutopilotSpecifyAltitude';
autoProfileHornetLead.AbsoluteAltitude = 2000; % ft
autoProfileHornetLead.AltitudeControlMode = 'eAutopilotAltitudeRate';
autoProfileHornetLead.ControlAltitudeRateValue = 2000; % ft/min
autoProfileHornetLead.ControlLimitMode = 'eOverride';
autoProfileHornetLead.MaxPitchRate = 10; % deg/s
autoProfileHornetLead.DampingRatio = 2;

% Set the airspeed options
autoProfileHornetLead.AirspeedOptions.AirspeedMode = 'eMaintainMaxEnduranceAirspeed';
autoProfileHornetLead.AirspeedOptions.MinSpeedLimits = 'eConstrainIfViolated';
autoProfileHornetLead.AirspeedOptions.MaxSpeedLimits = 'eConstrainIfViolated';

%%% Set the attitude/performance/fuel options
basicManeuverHornetLead.FlightMode = 'eFlightPhaseCruise';
basicManeuverHornetLead.FuelFlowType = 'eBasicManeuverFuelFlowCruise';

%%% Set the basic stop conditions
basicManeuverHornetLead.UseStopFuelState = true;
basicManeuverHornetLead.StopFuelState = 2000; % lb
basicManeuverHornetLead.UseMaxTimeOfFlight = false;
basicManeuverHornetLead.UseMaxDownrange = true;
basicManeuverHornetLead.MaxDownrange = 500; % nm

basicManeuverHornetLead.AltitudeLimitMode = 'eBasicManeuverAltLimitError';
basicManeuverHornetLead.TerrainImpactMode = 'eBasicManeuverAltLimitContinue';

%% Add a Basic Maneuver to "Enter Break"

% Update waitbar
waitbar(.50,f,'Lead hornet - adding maneuever to enter break');

% Add a Basic Maneuver procedure from the end of the previous procedure
basicManeuver2HornetLead = procedures2HornetLead.Add('eSiteEndOfPrevProcedure','eProcBasicManeuver');

% Set the site name
basicManeuver2HornetLead.Site.Name = 'Mother';

%%% Set the procedure properties

% Set procedure name
basicManeuver2HornetLead.Name = 'Enter Break';

%%% Set the horizontal/navigation strategy
basicManeuver2HornetLead.NavigationStrategyType = 'Relative Course';

% Get the navigation interface
relCourse = basicManeuver2HornetLead.Navigation;

% Set the target
relCourse.TargetName = 'Ship/CVN-72';

% Set relative or true course option
relCourse.UseRelativeCourse = true;
relCourse.Course = 0; % deg

% Set the anchor offset
relCourse.InTrack = 1; % nm
relCourse.CrossTrack = 0; % nm

% Set other options
relCourse.UseApproachTurnMode = true;

% Set closure mode
relCourse.ClosureMode = 'eHOBS';
relCourse.DownrangeOffset = 0; % nm
relCourse.HOBSMaxAngle =  90; % deg

%%% Set the vertical/profile strategy
basicManeuver2HornetLead.ProfileStrategyType = 'Autopilot - Vertical Plane';

% Get the profile interface
autoProfile2HornetLead = basicManeuver2HornetLead.Profile;

% Set the altitude options
autoProfile2HornetLead.AltitudeMode = 'eAutopilotSpecifyAltitude';
autoProfile2HornetLead.AbsoluteAltitude = 800; % ft
autoProfile2HornetLead.AltitudeControlMode = 'eAutopilotAltitudeRate';
autoProfile2HornetLead.ControlAltitudeRateValue = 2000; % ft/min
autoProfile2HornetLead.ControlLimitMode = 'eOverride';
autoProfile2HornetLead.MaxPitchRate = 10; % deg/s
autoProfile2HornetLead.DampingRatio = 2;

% Set the airspeed options
autoProfile2HornetLead.AirspeedOptions.AirspeedMode = 'eMaintainSpecifiedAirspeed';
autoProfile2HornetLead.AirspeedOptions.SpecifiedAirspeedType = 'eCAS';
autoProfile2HornetLead.AirspeedOptions.SpecifiedAirspeed = 350; % nm/hr
autoProfile2HornetLead.AirspeedOptions.MinSpeedLimits = 'eConstrainIfViolated';
autoProfile2HornetLead.AirspeedOptions.MaxSpeedLimits = 'eConstrainIfViolated';

%%% Set the attitude/performance/fuel options
basicManeuver2HornetLead.FlightMode = 'eFlightPhaseCruise';
basicManeuver2HornetLead.FuelFlowType = 'eBasicManeuverFuelFlowCruise';

%%% Set the basic stop conditions
basicManeuver2HornetLead.UseStopFuelState = true;
basicManeuver2HornetLead.StopFuelState = 0; % lb
basicManeuver2HornetLead.UseMaxTimeOfFlight = false;
basicManeuver2HornetLead.UseMaxDownrange = true;
basicManeuver2HornetLead.MaxDownrange = 100; % nm

basicManeuver2HornetLead.AltitudeLimitMode = 'eBasicManeuverAltLimitError';
basicManeuver2HornetLead.TerrainImpactMode = 'eBasicManeuverAltLimitContinue';

%% Add a Basic Maneuver Procedure to "Break"

% Update waitbar
waitbar(.55,f,'Lead hornet - adding maneuever to break');

% Add a Basic Maneuver procedure from the end of the previous procedure
basicManeuver3HornetLead = procedures2HornetLead.Add('eSiteEndOfPrevProcedure','eProcBasicManeuver');

%%% Set the procedure properties

% Set procedure name
basicManeuver3HornetLead.Name = 'Break';

%%% Set the horizontal/navigation strategy
basicManeuver3HornetLead.NavigationStrategyType = 'Relative Course';

% Get the navigation interface
relCourse2 = basicManeuver3HornetLead.Navigation;

% Set the target
relCourse2.TargetName = 'Ship/CVN-72';

% Set relative or true course option
relCourse2.UseRelativeCourse = true;
relCourse2.Course = 180; % deg

% Set the anchor offset
relCourse2.InTrack = 0; % nm
relCourse2.CrossTrack = -1.3; % nm

% Set other options
relCourse2.UseApproachTurnMode = true;

% Set maneuver factor
relCourse2.ManeuverFactor = 1.00; % aggressive

% Set control limit
relCourse2.SetControlLimit('eNavMaxTurnRate',29.9725); % deg/s

% Set closure mode
relCourse2.ClosureMode = 'eHOBS';
relCourse2.DownrangeOffset = 0; % nm
relCourse2.HOBSMaxAngle =  90; % deg

%%% Set the vertical/profile strategy
basicManeuver3HornetLead.ProfileStrategyType = 'Autopilot - Vertical Plane';

% Get the profile interface
autoProfile3HornetLead = basicManeuver3HornetLead.Profile;

% Set the altitude options
autoProfile3HornetLead.AltitudeMode = 'eAutopilotSpecifyAltitude';
autoProfile3HornetLead.AbsoluteAltitude = 600; % ft
autoProfile3HornetLead.AltitudeControlMode = 'eAutopilotAltitudeRate';
autoProfile3HornetLead.ControlAltitudeRateValue = 2000; % ft/min
autoProfile3HornetLead.ControlLimitMode = 'eOverride';
autoProfile3HornetLead.MaxPitchRate = 10; % deg/s
autoProfile3HornetLead.DampingRatio = 2;

% Set the airspeed options
autoProfile3HornetLead.AirspeedOptions.AirspeedMode = 'eMaintainSpecifiedAirspeed';
autoProfile3HornetLead.AirspeedOptions.SpecifiedAirspeedType = 'eCAS';
autoProfile3HornetLead.AirspeedOptions.SpecifiedAirspeed = 145; % nm/hr
autoProfile3HornetLead.AirspeedOptions.SpecifiedAccelDecelMode = 'eOverride';
autoProfile3HornetLead.AirspeedOptions.SpecifiedAccelDecelG = 0.3; % G's
autoProfile3HornetLead.AirspeedOptions.MinSpeedLimits = 'eConstrainIfViolated';
autoProfile3HornetLead.AirspeedOptions.MaxSpeedLimits = 'eConstrainIfViolated';

%%% Set the attitude/performance/fuel options
basicManeuver3HornetLead.FlightMode = 'eFlightPhaseCruise';
basicManeuver3HornetLead.FuelFlowType = 'eBasicManeuverFuelFlowCruise';

%%% Set the basic stop conditions
basicManeuver3HornetLead.UseStopFuelState = true;
basicManeuver3HornetLead.StopFuelState = 0; % lb
basicManeuver3HornetLead.UseMaxTimeOfFlight = false;
basicManeuver3HornetLead.UseMaxDownrange = true;
basicManeuver3HornetLead.MaxDownrange = 50; % nm

basicManeuver3HornetLead.AltitudeLimitMode = 'eBasicManeuverAltLimitError';
basicManeuver3HornetLead.TerrainImpactMode = 'eBasicManeuverAltLimitContinue';

%% Add a Basic Maneuver Procedure to "Recover" (Land on Ship)

% Update waitbar
waitbar(.60,f,'Lead hornet - adding maneuever to recover');

% Add a Basic Maneuver procedure from the end of the previous procedure
basicManeuver4HornetLead = procedures2HornetLead.Add('eSiteEndOfPrevProcedure','eProcBasicManeuver');

%%% Set the procedure properties

% Set procedure name
basicManeuver4HornetLead.Name = 'Recover';

%%% Set the horizontal/navigation strategy
basicManeuver4HornetLead.NavigationStrategyType = 'Relative Course';

% Get the navigation interface
relCourse3 = basicManeuver4HornetLead.Navigation;

% Set the target
relCourse3.TargetName = 'Ship/CVN-72';

% Set relative or true course option
relCourse3.UseRelativeCourse = true;
relCourse3.Course = -9.0; % deg

% Set the anchor offset
stkRoot.UnitPreferences.Item('AviatorDistance').SetCurrentUnit('ft');
relCourse3.InTrack = -850; % ft
relCourse3.CrossTrack = 75; % ft
stkRoot.UnitPreferences.Item('AviatorDistance').SetCurrentUnit('nm');

% Set other options
relCourse3.UseApproachTurnMode = true;

% Set closure mode
relCourse3.ClosureMode = 'eHOBS';
relCourse3.DownrangeOffset = 0.1; % nm
relCourse3.HOBSMaxAngle =  90; % deg

%%% Set the vertical/profile strategy
basicManeuver4HornetLead.ProfileStrategyType = 'Relative Flight Path Angle';

% Get the profile interface
relFpa = basicManeuver4HornetLead.Profile;

% Set FPA and anchor alt offset
relFpa.FPA = -3.5; % deg
relFpa.AnchorAltOffset = 100; % ft

% Set control limit
relFpa.SetControlLimit('eProfilePitchRate',10); % deg/s

% Set airspeed options
relFpa.AirspeedOptions.AirspeedMode = 'eMaintainCurrentAirspeed';
relFpa.AirspeedOptions.MaintainAirspeedType = 'eTAS';
relFpa.AirspeedOptions.MinSpeedLimits = 'eConstrainIfViolated';
relFpa.AirspeedOptions.MaxSpeedLimits = 'eConstrainIfViolated';

%%% Set the attitude/performance/fuel options
basicManeuver4HornetLead.FlightMode = 'eFlightPhaseCruise';
basicManeuver4HornetLead.FuelFlowType = 'eBasicManeuverFuelFlowCruise';

%%% Set the basic stop conditions
basicManeuver4HornetLead.UseStopFuelState = true;
basicManeuver4HornetLead.StopFuelState = 0; % lb
basicManeuver4HornetLead.UseMaxTimeOfFlight = false;
basicManeuver4HornetLead.UseMaxDownrange = true;
basicManeuver4HornetLead.MaxDownrange = 50; % nm

basicManeuver4HornetLead.AltitudeLimitMode = 'eBasicManeuverAltLimitError';
basicManeuver4HornetLead.TerrainImpactMode = 'eBasicManeuverAltLimitContinue';

% Propagate aircraft
avtrPropHornetLead.Propagate();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create Wingman Hornet Aircraft to Fly Formation with Lead
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Update waitbar
waitbar(.70,f,'Creating wingman hornet aircraft');

aircraftHornetWing = scenario.Children.New('eAircraft','Hornet_Flight_Wing');

% Set propagator to Aviator
aircraftHornetWing.SetRouteType('ePropagatorAviator');

% Grab the Aviator Propagator
avtrPropHornetWing = aircraftHornetWing.Route.AvtrPropagator;

% Grab the mission
avtrMissionHornetWing = avtrPropHornetWing.AvtrMission;

% Set the aircraft model to Basic Fighter Copy
avtrMissionHornetWing.Vehicle = basicFighter;

% From the mission grab the phase collection
phasesHornetWing = avtrMissionHornetWing.Phases;

% Get the first phase
phaseHornetWing = phasesHornetWing.Item(0);

% Get the procedure collection
proceduresHornetWing = phaseHornetWing.Procedures;

% Set display properties
aircraftHornetWing.Graphics.Attributes.Color = 16724991; % magenta
aircraftHornetWing.Graphics.Attributes.Line.Width = 'e3'; % medium thickness

%% Add an Enroute Procedure to Begin Flying to Lead

%%% Aircraft starts at a waypoint south of the lead aircraft, already
%%% flying.

% Update waitbar
waitbar(.75,f,'Wing hornet - adding enroute procedure to approach Lead hornet');

enrouteHornetWing = proceduresHornetWing.Add('eSiteWaypoint','eProcEnroute');

%%% Set the site properties
enrouteHornetWingSite = enrouteHornetWing.Site;
enrouteHornetWingSite.Name = 'Waypoint';
enrouteHornetWingSite.Latitude = 36.3174; % deg
enrouteHornetWingSite.Longitude = -75.4974; % deg

%%% Set the procedure properties

% Set the altitude options
enrouteHornetWing.AltitudeMSLOptions.UseDefaultCruiseAltitude = true;

% Set the navigation options
enrouteHornetWing.NavigationOptions.NavMode = 'eArriveOnCourse';
enrouteHornetWing.NavigationOptions.ArriveOnCourse = 340.691; % deg

%% Add a Basic Maneuver Procedure to "Intercept Leader"

% Update waitbar
waitbar(.80,f,'Wing hornet - adding maneuver to intercept Lead hornet');

% Add a Basic Maneuver procedure from the end of the previous procedure
basicManeuverHornetWing = proceduresHornetWing.Add('eSiteEndOfPrevProcedure','eProcBasicManeuver');

%%% Set the procedure properties

% Set procedure name
basicManeuverHornetWing.Name = 'Intercept Leader';

%%% Set the horizontal/navigation strategy
basicManeuverHornetWing.NavigationStrategyType = 'Relative Bearing';

% Get the navigation interface
relBearing = basicManeuverHornetWing.Navigation;

% Set the target
relBearing.TargetName = 'Aircraft/Hornet_Flight_Lead';

% Set relative bearing values
relBearing.RelBearing = -20; % deg
relBearing.MinRange = 15; % nm

% Set control limits
relBearing.SetControlLimit('eNavUseAccelPerfModel',0);

%%% Set the vertical/profile strategy
basicManeuverHornetWing.ProfileStrategyType = 'Cruise Profile';

% Get the profile interface
cruiseProfileHornetWing = basicManeuverHornetWing.Profile;

% Set the reference frame
cruiseProfileHornetWing.ReferenceFrame = 'eEarthFrame';

% Set the altitude options
cruiseProfileHornetWing.RequestedAltitude = 18000; % ft

% Set cruise airspeed
cruiseProfileHornetWing.CruiseAirspeedOptions.CruiseSpeedType = 'eMaxRangeAirspeed';

%%% Set the attitude/performance/fuel options
basicManeuverHornetWing.FlightMode = 'eFlightPhaseCruise';
basicManeuverHornetWing.FuelFlowType = 'eBasicManeuverFuelFlowCruise';

%%% Set the basic stop conditions
basicManeuverHornetWing.UseStopFuelState = true;
basicManeuverHornetWing.StopFuelState = 0.0;
basicManeuverHornetWing.UseMaxTimeOfFlight = false;
basicManeuverHornetWing.UseMaxDownrange = false;

basicManeuverHornetWing.AltitudeLimitMode = 'eBasicManeuverAltLimitError';
basicManeuverHornetWing.TerrainImpactMode = 'eBasicManeuverAltLimitContinue';

%% Add a Basic Maneuver Procedure to "Fly Formation to Marshall"

% Update waitbar
waitbar(.85,f,'Wing hornet - adding maneuver to fly in formation to Marshall');

% Add a Basic Maneuver procedure from the end of the previous procedure
basicManeuver2HornetWing = proceduresHornetWing.Add('eSiteEndOfPrevProcedure','eProcBasicManeuver');

%%% Set the procedure properties

% Set procedure name
basicManeuver2HornetWing.Name = 'Fly Formation to Marshall';

%%% Set the horizontal/navigation strategy
basicManeuver2HornetWing.NavigationStrategyType = 'Rendezvous/Formation';

% Get the navigation interface
rendezvousForm = basicManeuver2HornetWing.Navigation;

% Set the cooperative target
rendezvousForm.TargetName = 'Aircraft/Hornet_Flight_Lead';

% Set the position options
rendezvousForm.RelativeBearing = 135; % deg
rendezvousForm.RelativeRange = 0.25; % nm
rendezvousForm.AltitudeSplit = 100; % ft

% Set the maneuver factor
rendezvousForm.ManeuverFactor = 0.8;

% Enable counter turn logic
rendezvousForm.UseCounterTurnLogic = true;

% Set the collision avoidance logic
rendezvousForm.SetCPA(true,152.4); % nm

% Set the airspeed control options
rendezvousForm.MaxSpeedAdvantage = 75; % nm/hr

% Set the rendezvous stop condition
rendezvousForm.StopCondition = 'eStopAfterTargetCurrentPhase';

%%% Set the vertical/profile strategy
% Profile settings are copied from the Navigation settings when using
% 'Rendezvous/Formation' as the nav mode.

%%% Set the attitude/performance/fuel options
basicManeuver2HornetWing.FlightMode = 'eFlightPhaseCruise';
basicManeuver2HornetWing.FuelFlowType = 'eBasicManeuverFuelFlowCruise';

%%% Set the basic stop conditions
basicManeuver2HornetWing.UseStopFuelState = false;
basicManeuver2HornetWing.UseMaxTimeOfFlight = false;
basicManeuver2HornetWing.UseMaxDownrange = true;
basicManeuver2HornetWing.MaxDownrange = 500; % nm

basicManeuver2HornetWing.AltitudeLimitMode = 'eBasicManeuverAltLimitError';
basicManeuver2HornetWing.TerrainImpactMode = 'eBasicManeuverAltLimitContinue';

%% Add a Basic Maneuver Procedure to "Split - Marshall - 3 Kft"

% Update waitbar
waitbar(.90,f,'Wing hornet - adding maneuver to fly Marshall at 3 Kft split from Lead hornet');

% Add a Basic Maneuver procedure from the end of the previous procedure
basicManeuver3HornetWing = proceduresHornetWing.Add('eSiteEndOfPrevProcedure','eProcBasicManeuver');

%%% Set the procedure properties

% Set procedure name
basicManeuver3HornetWing.Name = 'Split - Marshall - 3 Kft';

%%% Set the horizontal/navigation strategy
basicManeuver3HornetWing.NavigationStrategyType = 'Stationkeeping';

% Get the navigation interface
stationkeepingNavHornetWing = basicManeuver3HornetWing.Navigation;

% Set stationkeeping target
stationkeepingNavHornetWing.TargetName = 'Ship/CVN-72';

% Set station options
stationkeepingNavHornetWing.RelBearing = -90; % deg
stationkeepingNavHornetWing.RelRange = 2.7; % nm
stationkeepingNavHornetWing.DesiredRadius = 2.5; % nm
stationkeepingNavHornetWing.TurnDirection = 'eTurnLeft';

% Set stop condition options
stationkeepingNavHornetWing.StopCondition = 'eStopAfterTurnCount';
stationkeepingNavHornetWing.StopAfterTurnCount = 5;
stationkeepingNavHornetWing.UseRelativeCourse = true;
stationkeepingNavHornetWing.StopCourse = -180; % deg

%%% Set the vertical/profile strategy
basicManeuver3HornetWing.ProfileStrategyType = 'Autopilot - Vertical Plane';

% Get the profile interface
autoProfileHornetWing = basicManeuver3HornetWing.Profile;

% Set the altitude options
autoProfileHornetWing.AltitudeMode = 'eAutopilotSpecifyAltitude';
autoProfileHornetWing.AbsoluteAltitude = 3000; % ft
autoProfileHornetWing.AltitudeControlMode = 'eAutopilotAltitudeRate';
autoProfileHornetWing.ControlAltitudeRateValue = 2000; % ft/min
autoProfileHornetWing.ControlLimitMode = 'eOverride';
autoProfileHornetWing.MaxPitchRate = 10; % deg/s
autoProfileHornetWing.DampingRatio = 2;

% Set the airspeed options
autoProfileHornetWing.AirspeedOptions.AirspeedMode = 'eMaintainMaxEnduranceAirspeed';
autoProfileHornetWing.AirspeedOptions.MinSpeedLimits = 'eConstrainIfViolated';
autoProfileHornetWing.AirspeedOptions.MaxSpeedLimits = 'eConstrainIfViolated';

%%% Set the attitude/performance/fuel options
basicManeuver3HornetWing.FlightMode = 'eFlightPhaseCruise';
basicManeuver3HornetWing.FuelFlowType = 'eBasicManeuverFuelFlowCruise';

%%% Set the basic stop conditions
basicManeuver3HornetWing.UseStopFuelState = false;
basicManeuver3HornetWing.UseMaxTimeOfFlight = false;
basicManeuver3HornetWing.UseMaxDownrange = true;
basicManeuver3HornetWing.MaxDownrange = 500; % nm

basicManeuver3HornetWing.AltitudeLimitMode = 'eBasicManeuverAltLimitError';
basicManeuver3HornetWing.TerrainImpactMode = 'eBasicManeuverAltLimitContinue';

%% Add a Basic Maneuver Procedure to "Marshall - Step Down - 2 Kft"

% Update waitbar
waitbar(.95,f,'Wing hornet - adding maneuver to fly Marshall stepped down to 2 Kft');

% Add a Basic Maneuver procedure from the end of the previous procedure
basicManeuver4HornetWing = proceduresHornetWing.Add('eSiteEndOfPrevProcedure','eProcBasicManeuver');

%%% Set the procedure properties

% Set procedure name
basicManeuver4HornetWing.Name = 'Marshall - Step Down - 2 Kft';

%%% Set the horizontal/navigation strategy
basicManeuver4HornetWing.NavigationStrategyType = 'Stationkeeping';

% Get the navigation interface
stationkeeping2NavHornetWing = basicManeuver4HornetWing.Navigation;

% Set stationkeeping target
stationkeeping2NavHornetWing.TargetName = 'Ship/CVN-72';

% Set station options
stationkeeping2NavHornetWing.RelBearing = -90; % deg
stationkeeping2NavHornetWing.RelRange = 2.7; % nm
stationkeeping2NavHornetWing.DesiredRadius = 2.5; % nm
stationkeeping2NavHornetWing.TurnDirection = 'eTurnLeft';

% Set stop condition options
stationkeeping2NavHornetWing.StopCondition = 'eStopAfterTurnCount';
stationkeeping2NavHornetWing.StopAfterTurnCount = 1;
stationkeeping2NavHornetWing.UseRelativeCourse = true;
stationkeeping2NavHornetWing.StopCourse = -180; % deg

%%% Set the vertical/profile strategy
basicManeuver4HornetWing.ProfileStrategyType = 'Autopilot - Vertical Plane';

% Get the profile interface
autoProfile2HornetWing = basicManeuver4HornetWing.Profile;

% Set the altitude options
autoProfile2HornetWing.AltitudeMode = 'eAutopilotSpecifyAltitude';
autoProfile2HornetWing.AbsoluteAltitude = 2000; % ft
autoProfile2HornetWing.AltitudeControlMode = 'eAutopilotAltitudeRate';
autoProfile2HornetWing.ControlAltitudeRateValue = 2000; % ft/min
autoProfile2HornetWing.ControlLimitMode = 'eOverride';
autoProfile2HornetWing.MaxPitchRate = 10; % deg/s
autoProfile2HornetWing.DampingRatio = 2;

% Set the airspeed options
autoProfile2HornetWing.AirspeedOptions.AirspeedMode = 'eMaintainMaxEnduranceAirspeed';
autoProfile2HornetWing.AirspeedOptions.MinSpeedLimits = 'eConstrainIfViolated';
autoProfile2HornetWing.AirspeedOptions.MaxSpeedLimits = 'eConstrainIfViolated';

%%% Set the attitude/performance/fuel options
basicManeuver4HornetWing.FlightMode = 'eFlightPhaseCruise';
basicManeuver4HornetWing.FuelFlowType = 'eBasicManeuverFuelFlowCruise';

%%% Set the basic stop conditions
basicManeuver4HornetWing.UseStopFuelState = true;
basicManeuver4HornetWing.StopFuelState = 0; % lb
basicManeuver4HornetWing.UseMaxTimeOfFlight = false;
basicManeuver4HornetWing.UseMaxDownrange = true;
basicManeuver4HornetWing.MaxDownrange = 500; % nm

basicManeuver4HornetWing.AltitudeLimitMode = 'eBasicManeuverAltLimitError';
basicManeuver4HornetWing.TerrainImpactMode = 'eBasicManeuverAltLimitContinue';

% Propagate aircraft
avtrPropHornetWing.Propagate();

% Update waitbar and then close
waitbar(1,f,'Scenario finished!');
pause(1);
close(f)

%%% End of Script
disp('Scenario... done!');
toc