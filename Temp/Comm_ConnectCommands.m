close all
clear all
clc

try
    % Grab an existing instance of STK
    uiapp = actxGetRunningServer('STK12.application');
    root = uiapp.Personality2;
    checkempty = root.Children.Count;
    if checkempty == 0
        %If a Scenario is not open, create a new scenario
        uiapp.visible = 1;
        root.NewScenario('TxRx');
        scenario = root.CurrentScenario;
    else
        %If a Scenario is open, prompt the user to accept closing it or not
        rtn = questdlg({'Close the current scenario?',' ','(WARNING: If you have not saved your progress will be lost)'});
        if ~strcmp(rtn,'Yes')
            return
        else
            root.CurrentScenario.Unload
            uiapp.visible = 1;
            root.NewScenario('TxRx');
            scenario = root.CurrentScenario;
        end
    end

catch
    % STK is not running, launch new instance
    % Launch a new instance of STK12 and grab it
    uiapp = actxserver('STK12.application');
    root = uiapp.Personality2;
    uiapp.visible = 1;
    root.NewScenario('TxRx');
    scenario = root.CurrentScenario;
end

%Get the path to the STK install directory
installDirectory = root.ExecuteCommand('GetDirectory / STKHome').Item(0);

%Create an area target
areaTarget = root.CurrentScenario.Children.New('eAreaTarget', 'dansArea');
areaTarget.AreaType = 'ePattern';
patterns = areaTarget.AreaTypeData;
patterns.Add(48.897, 18.637);
patterns.Add(46.534, 13.919);
patterns.Add(44.173, 21.476);

%set units to utcg before setting scenario time period and animation period
root.UnitPreferences.Item('DateFormat').SetCurrentUnit('UTCG');

%set scenario time period and animation period
root.CurrentScenario.SetTimePeriod('1 Jul 2013 12:00:00.000', '5 Jul 2013 12:00:00.000');
root.CurrentScenario.Epoch = '1 Jul 2013 12:00:00.000';

%create satellite and fac
satObj = root.CurrentScenario.Children.New('eSatellite', 'Satellite1');
facObj = root.CurrentScenario.Children.New('eFacility', 'Facility1');

%configure the facility's lighting constraint
oLightConstraint = facObj.AccessConstraints.AddConstraint('eCstrLighting');
oLightConstraint.Condition = 'eDirectSun';

%propagate sat...
satObj.Propagator.InitialState.Representation.AssignCartesian('eCoordinateSystemJ2000', -6465.513055, 5630.194365, 0.0, 1.712713627, 0.841292034, 7.377687805);
satObj.Propagator.EphemerisInterval.SetStartAndStopTimes('1 Jul 2007 12:00:00.00', '2 Jul 2007 12:00:00.00')
satObj.Propagator.Propagate;

root.Rewind;

%%Create a custom VGT point for the facility
%get the vgt root
vgtRoot = root.Vgt;

%get the IAgCrdnProvider for the facility
facVGT = facObj.Vgt;

%create the IAgCrdnPointFixedInSystem point for the facility
facPoint = facVGT.Points.Factory.Create('fixedPoint', 'point fixed in system', 'eCrdnPointTypeFixedInSystem');
facPoint.Reference.SetSystem(facVGT.Systems.Item('Body'));
facPoint.FixedPoint.AssignCartesian(1, 1, -1);

%get the IAgVORefCrdnPoint
facPointVO = facObj.VO.Vector.RefCrdns.Add('ePointElem', facPoint.QualifiedPath);
facPointVO.LabelVisible = 0;

%%Add a sensor to the satellite
%create a sensor
senObj = satObj.Children.New('eSensor', 'Sensor1');

%set the sensor type to rectangular, define the half angles
senObj.SetPatternType('eSnRectangular');
senObj.Pattern.HorizontalHalfAngle = 15;
senObj.Pattern.VerticalHalfAngle = 45;

%Create a unit velocity vector scaled by some random scalar
vectorVelocityUnit = satObj.Vgt.Vectors.Factory.Create('VelocityUnit','Scaled (Normalised) Vector Sat1 Velocity','eCrdnVectorTypeScalarScaled');
vectorVelocityUnit.Normalize = 1; %Set 1 for true, 0 for false
vectorVelocityUnit.ScaleFactor = 1;
vectorVelocityUnit.InputVector = satObj.Vgt.Vectors.Item('Velocity');
vectorVelocityUnit.InputScalar = satObj.Vgt.CalcScalars.Item('Trajectory(CBF).Cartesian.X');
vectorVelocityUnit.DimensionInheritance = 0; %Set 1 for true, 0 for false
vectorVelocityUnit.Dimension = 'SmallVelocityUnit';

%visualize this vector
try
    %if this fails, then the vector does not exist in the list
    voVec = satObj.VO.Vector.RefCrdns.GetCrdnByName('eVectorElem', vectorVelocityUnit.QualifiedPath);
catch
    voVec = satObj.VO.Vector.RefCrdns.Add('eVectorElem', vectorVelocityUnit.QualifiedPath);
end
voVec.MagnitudeVisible = 1;
voVec.Color = hex2dec('ff6ff2');
satObj.VO.Vector.ScaleRelativeToModel = 1;
satObj.VO.Vector.VectorSizeScale = 1.3;

%get a handle to the satellite's sun vector
sunVec = satObj.Vgt.Vectors.Item('Sun');

%visualize the sun vector
try
    %if this fails, then the vector does not exist in the list
    sunVoVec = satObj.VO.Vector.RefCrdns.GetCrdnByName('eVectorElem', sunVec.QualifiedPath);
catch
    sunVoVec = satObj.VO.Vector.RefCrdns.Add('eVectorElem', sunVec.QualifiedPath);
end
sunVoVec.Visible = 1;
sunVoVec.Color = 65535;

%Create a vector describing the solar panel orientation
vectorSolarPanels = satObj.Vgt.Vectors.Factory.Create('SolarPanels','SolarPanel Direction','eCrdnVectorTypeFixedInAxes');
vectorSolarPanels.Direction.AssignXYZ(0, 0, 0);

%get a handle to the satellite's sun vector
sunVec = satObj.Vgt.Vectors.Item('Sun');

%% Create Angle
%Between solar panel and the sun
angleaxis_ECI = satObj.Vgt.Angles.Factory.Create('ANGLE','angle','eCrdnAngleTypeBetweenVectors');
angleaxis_ECI.FromVector.SetVector(sunVec);
angleaxis_ECI.ToVector.SetVector(vectorSolarPanels);
%visualize this angle
voVec = satObj.VO.Vector.RefCrdns.Add('eAngleElem', angleaxis_ECI.QualifiedPath);
voVec.Color = hex2dec('00BFFF'); % yellow


%% ADD A TRANSMITTER AND RECEIVER
txObj = facObj.Children.New('eTransmitter', 'UplinkTx');
rxObj = senObj.Children.New('eReceiver', 'UplinkRx');

%set up the reciever object
root.ExecuteCommand('Receiver */Satellite/Satellite1/Sensor/Sensor1/Receiver/UplinkRx SetValue Model Complex_Receiver_Model');
root.ExecuteCommand(['Receiver */Satellite/' satObj.InstanceName '/Sensor/' senObj.InstanceName '/Receiver/' rxObj.InstanceName ' SetValue Model.AntennaControl.Antenna Parabolic']);
root.ExecuteCommand(['Receiver */Satellite/' satObj.InstanceName '/Sensor/' senObj.InstanceName '/Receiver/' rxObj.InstanceName ' SetValue Model.AntennaControl.Antenna.Diameter 2.5']);
root.ExecuteCommand(['Receiver */Satellite/' satObj.InstanceName '/Sensor/' senObj.InstanceName '/Receiver/' rxObj.InstanceName ' SetValue Model.FrequencyAutoTracking false']); %fancy way of specifying the path
root.ExecuteCommand(['Receiver */Satellite/' satObj.InstanceName '/Sensor/' senObj.InstanceName '/Receiver/' rxObj.InstanceName ' SetValue Model.Frequency 790500000']);
root.ExecuteCommand(['Receiver */Satellite/' satObj.InstanceName '/Sensor/' senObj.InstanceName '/Receiver/' rxObj.InstanceName ' SetValue Model.AutoScaleBandwidth false']);
root.ExecuteCommand(['Receiver */Satellite/' satObj.InstanceName '/Sensor/' senObj.InstanceName '/Receiver/' rxObj.InstanceName ' SetValue Model.Bandwidth 5000000.00000000']);

root.ExecuteCommand('Transmitter */Facility/Facility1/Transmitter/UplinkTx SetValue Model Complex_Transmitter_Model');
root.ExecuteCommand(['Transmitter */Facility/' facObj.InstanceName '/Transmitter/' txObj.InstanceName ' SetValue Model.AntennaControl.Antenna External_Antenna_Pattern']);
root.ExecuteCommand(['Transmitter */Facility/' facObj.InstanceName '/Transmitter/' txObj.InstanceName ' SetValue Model.AntennaControl.Antenna.ExternalAntennaFile ' installDirectory 'Data\Resources\stktraining\text\PhiThetaPattern_Gaussian_Quadrant1-3.txt']);
root.ExecuteCommand(['Transmitter */Facility/' facObj.InstanceName '/Transmitter/' txObj.InstanceName ' SetValue Model.Frequency 760500000']);
root.ExecuteCommand(['Transmitter */Facility/' facObj.InstanceName '/Transmitter/' txObj.InstanceName ' SetValue Model.Power 2511.89']);
root.ExecuteCommand(['Transmitter */Facility/' facObj.InstanceName '/Transmitter/' txObj.InstanceName ' SetValue Model.Modulator.AutoScaleBandwidth false']);
root.ExecuteCommand(['Transmitter */Facility/' facObj.InstanceName '/Transmitter/' txObj.InstanceName ' SetValue Model.Modulator.SymmetricBandwidth true']);
root.ExecuteCommand(['Transmitter */Facility/' facObj.InstanceName '/Transmitter/' txObj.InstanceName ' SetValue Model.Modulator.Bandwidth 5000000.00000000']);
root.ExecuteCommand(['Transmitter */Facility/' facObj.InstanceName '/Transmitter/' txObj.InstanceName ' SetValue Model.AntennaControl.Orientation.AzimuthAngle 1.57079633']); %90 deg in rad
root.ExecuteCommand(['Transmitter */Facility/' facObj.InstanceName '/Transmitter/' txObj.InstanceName ' SetValue Model.AntennaControl.Orientation.ElevationAngle 0.0']);

%Some examples of how I pull back data on the tx/rx, which I use to set the
%values in the SetValue commands
val = root.ExecuteCommand('Transmitter_RM */Facility/Facility1/Transmitter/UplinkTx GetValue');
for i = 1:val.Count - 1
    disp(val.Item(i))
end

val = root.ExecuteCommand('Receiver_RM */Satellite/Satellite1/Sensor/Sensor1/Receiver/UplinkRx GetValue Model.AntennaControl');
for i = 1:val.Count - 1
    disp(val.Item(i))
end

%%Turn on the visualization of the antennas
root.ExecuteCommand('VO */Facility/Facility1/Transmitter/UplinkTx Volumes "Antenna Beam" WireFrame On');
root.ExecuteCommand('VO */Facility/Facility1/Transmitter/UplinkTx Volumes "Antenna Beam" GainScale 55.0');
root.ExecuteCommand('VO */Facility/Facility1/Transmitter/UplinkTx Volumes "Antenna Beam" GainOffset 30.0');
root.ExecuteCommand('VO */Facility/Facility1/Transmitter/UplinkTx Volumes "Antenna Beam" Pattern 51 0.0 360.0 101 -180 0.0');