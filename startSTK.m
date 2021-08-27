%%% PRELIMINARY STUFF
% clear; clc


%%% LAUNCHING STK
%Create an instance of STK
uiApplication = actxserver('STK12.Application');
uiApplication.Visible = 1;

%Get our IAgStkObjectRoot interface
root = uiApplication.Personality2;
disp("Started STK")


%%% SCENARIO SETTINGS
% Create a new scenario 
scenario = root.Children.New('eScenario',scenario_name);

% Scenario time properties
scenario.SetTimePeriod(scenario_times(1),scenario_times(2))
scenario.StartTime = scenario_times(1);
scenario.StopTime = scenario_times(2);
disp("Scenario Created")

%{
%%% ANIMATION AND GRPAHICS SETTINGS
% Reset animation period (because its necessary)
% Connect Command > root.ExecuteCommand('Animate * Reset')
root.Rewind;
%}

%%% DONE
disp("DONE")
