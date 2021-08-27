%This is an example of how to use Matlab to create a scenario, add a satellite, add constraints and compute revisit time for that satellite.  Additionally this uses Grid Inspector Tool. 

%To run this code simply open STK with no scenario running.
%Requires STK, STK Coverage and STK Integration licenses.
clc
clear all
% % 
% % % Initialize 
try
    % Grab an existing instance of STK
    uiapp = actxGetRunningServer('STK12.application');
    root = uiapp.Personality2;
    checkempty = root.Children.Count;
    if checkempty == 0
        %If a Scenario is not open, create a new scenario
        uiapp.visible = 1;
        root.NewScenario('Coverage_Example');
        scenario = root.CurrentScenario;
    else
        %If a Scenario is open, prompt the user to accept closing it or not
        rtn = questdlg({'Close the current scenario?',' ','(WARNING: If you have not saved your progress will be lost)'});
        if ~strcmp(rtn,'Yes')
            return
        else
            root.CurrentScenario.Unload
            uiapp.visible = 1;
            root.NewScenario('Coverage Example');
            scenario = root.CurrentScenario;
        end
    end

catch
    % STK is not running, launch new instance
    % Launch a new instance of STK12 and grab it
    uiapp = actxserver('STK12.application');
    root = uiapp.Personality2;
    uiapp.visible = 1;
    root.NewScenario('Coverage_Example');
    scenario = root.CurrentScenario;
end

%%create a new satellite object named "Satellite1"
satellite = scenario.Children.New('eSatellite', 'Satellite1');
satellite.Propagator.Propagate;

covDef = scenario.Children.New('eCoverageDefinition','CovDef');
covDef.AssetList.Add(satellite.Path);
covDef.ComputeAccesses();

fom = covDef.Children.New('eFigureofMerit','Fom');
fom.SetDefinitionType('eFmRevisitTime');
fom.Definition.Satisfaction.EnableSatisfaction = true;

% Find min/max FOM value for static contours
overallValDP = fom.DataProviders.GetDataPrvFixedFromPath('Overall Value');
Result_1 = overallValDP.Exec();
min = cell2mat(Result_1.DataSets.GetDataSetByName('Minimum').GetValues);
max = cell2mat(Result_1.DataSets.GetDataSetByName('Maximum').GetValues);

satisfaction = covDef.Graphics.Static;
Animation = fom.VO.Animation;
Animation.IsVisible = false;
VOcontours = fom.VO.Static;
VOcontours.IsVisible = true;
contours = fom.Graphics.Static.Contours;
contours.IsVisible = true;
contours.ContourType = 'eSmoothFill';
contours.ColorMethod = 'eColorRamp';
contours.LevelAttributes.RemoveAll;

contours.LevelAttributes.AddLevelRange(min, max, (max-min)/10);   %Start, Start, Step
contours.RampColor.StartColor = 255;        %Red
contours.RampColor.EndColor = 16711680;     %Blue

%Pulls the Percent Satisfied as a value
staticSatDP = fom.DataProviders.GetDataPrvFixedFromPath('Static Satisfaction');
Result_2 = staticSatDP.Exec();
Percent_1 = cell2mat(Result_2.DataSets.GetDataSetByName('Percent Satisfied').GetValues)

%Gets Grid Inspector Tool Data
%This allows you to put in a Lat/Lon for the grid inspector 
gridInspector = fom.GridInspector;
Lat = 42.1429;
Lon = 4.00000;
gridInspector.SelectPoint(Lat,Lon);

%Outputs the same message as in the Grid Inspector
gridInspector.Message

%COMPUTE ACCESS HERE

%This is the value for Start Time from Execture Single (ans_Interval)
%The next is value for Duration of the Revisit Time (ans_Duration)
pointFOM = gridInspector.PointFOM;
pointFOMResult = pointFOM.Exec('30 Jun 2015 04:00:00.000','31 Jun 2015 04:00:00.000',60)
disp(pointFOMResult.DataSets.Count)
answer = pointFOMResult.DataSets.GetRow(0);
ans_Interval = cell2mat(answer(1))
ans_Duration = cell2mat(answer(2))

