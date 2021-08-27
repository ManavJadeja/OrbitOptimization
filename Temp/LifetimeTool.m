%%%%%%%%%%%%%%%%%%%%%%%%% MATLAB INITIALIZATION %%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear all
clc

%Initialize 
%Establish the connection
try
    % Grab an existing instance of STK
    uiapp = actxGetRunningServer('STK12.application');
    root = uiapp.Personality2;
    checkempty = root.Children.Count;
    if checkempty == 0
        %If a Scenario is not open, create a new scenario
        uiapp.visible = 1;
        root.NewScenario('Satellite_Lifetime');
        scenario = root.CurrentScenario;
    else
        %If a Scenario is open, prompt the user to accept closing it or not
        rtn = questdlg({'Close the current scenario?',' ','(WARNING: If you have not saved your progress will be lost)'});
        if ~strcmp(rtn,'Yes')
            return
        else
            root.CurrentScenario.Unload
            uiapp.visible = 1;
            root.NewScenario('Satellite Lifetime');
            scenario = root.CurrentScenario;
        end
    end

catch
    % STK is not running, launch new instance
    % Launch a new instance of STK12 and grab it
    uiapp = actxserver('STK12.application');
    root = uiapp.Personality2;
    uiapp.visible = 1;
    root.NewScenario('Satellite_Lifetime');
    scenario = root.CurrentScenario;
end

%set units to utcg before setting scenario time period and animation period
root.UnitPreferences.Item('DateFormat').SetCurrentUnit('UTCG');

%set scenario time period and animation period
root.CurrentScenario.SetTimePeriod('1 Jul 2021 12:00:00.000', '2 Jul 2021 12:00:00.000');
root.CurrentScenario.Epoch = '1 Jul 2021 12:00:00.000';
root.CurrentScenario.Animation.EnableAnimCycleTime = true;
root.CurrentScenario.Animation.AnimCycleType = 'eEndTime';
root.CurrentScenario.Animation.AnimCycleTime = '2 Jul 2021 12:00:00.000';
root.CurrentScenario.Animation.StartTime = '1 Jul 2021 12:00:00.000';
root.CurrentScenario.Animation.EnableAnimCycleTime = false;

root.Rewind();

root.ExecuteCommand('SetUnits / km sec UTCG');

root.ExecuteCommand('New / */Satellite Sat');
root.ExecuteCommand('SetState */Satellite/Sat Cartesian J2Perturbation "1 Jul 2021 12:00:00.00" "2 Jul 2021 12:00:00.00" 60 J2000 "1 Jul 2021 12:00:00.00" 6528.14 0.0 0.0 0.0 1.38869 7.87566');

% set parameters for lifetime calculation
% SetLifetime <SatObjectPath> {LifeOption} <Value>
root.ExecuteCommand('SetLifetime */Satellite/Sat DragCoeff 2.2 ReflectCoeff 1 DragArea 5 SunArea 5 Mass 500 DecayAltitude 0 FluxSigmaLevel 1 2ndOrder On Rotate On Graphics Off DensityModel Jacchia71');

% compute lifetime
result = root.ExecuteCommand('Lifetime */Satellite/Sat');

% display the result from the command
disp(result.Item(0))

%parse this out into a variable
split_result = regexp(result.Item(0), ' ', 'split');

date_of_decay = [split_result{8} ' ' split_result{9} ' ' split_result{10} ' ' split_result{11}]
num_of_orbits = str2num(split_result{13})
orb_lifetime = str2num(split_result{17}) %days