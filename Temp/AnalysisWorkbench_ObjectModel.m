try
    % Grab an existing instance of STK
    uiapp = actxGetRunningServer('STK12.application');
    root = uiapp.Personality2;
    checkempty = root.Children.Count;
    disp(checkempty)
    if checkempty == 0
        %If a Scenario is not open, create a new scenario
        uiapp.visible = 1;
        root.NewScenario('CreateVGT');
        scenario = root.CurrentScenario;
    else
        %If a Scenario is open, prompt the user to accept closing it or not
        rtn = questdlg({'Close the current scenario?',' ','(WARNING: If you have not saved your progress will be lost)'});
        if ~strcmp(rtn,'Yes')
            return
        else
            root.CurrentScenario.Unload
            uiapp.visible = 1;
            root.NewScenario('CreateVGT');
            scenario = root.CurrentScenario;
        end
    end

catch
    % STK is not running, launch new instance
    % Launch a new instance of STK12 and grab it
    uiapp = actxserver('STK12.application');
    root = uiapp.Personality2;
    uiapp.visible = 1;
    root.NewScenario('CreateVGT');
    scenario = root.CurrentScenario;
end

root.UnitPreferences.Item('DateFormat').SetCurrentUnit('EpSec');
root.UnitPreferences.Item('Angle').SetCurrentUnit('Deg');

sat = scenario.Children.New('eSatellite','sat');
sat.Propagator.InitialState.Representation.AssignClassical('eCoordinateSystemICRF',10000,0,15,0,180,0);
sat.Propagator.Propagate;

%--------------------
%****VGT EXAMPLES****
%--------------------

%Get handle to VGT Center point defined on Earth CB
centerPtEarth = root.CentralBodies.Earth.Vgt.Points.Item('Center');
icrf = root.CentralBodies.Earth.Vgt.Systems.Item('ICRF');

%Get the satellite vgt interface
vgtSat = sat.vgt;
%Get handle to the Center point on the satellite
centerPtSat = vgtSat.Points.Item('Center');
%Get handle to the Body Y Vector
bodyYSat = vgtSat.Vectors.Item('Body.Y');
%Get handle to the Body Axes
bodyAxes = vgtSat.Axes.Item('Body');
icrfAxes = vgtSat.Axes.Item('ICRF');

%Create a new Vector
VectFactory = vgtSat.Vectors.Factory;
Sat2EarthCenter = VectFactory.CreateDisplacementVector('Sat2EarthCenter',centerPtSat,centerPtEarth);

%Create a new Point
PtFactory = vgtSat.Points.Factory;
fixedPt = PtFactory.Create('FixedPt','Point offest from Center','eCrdnPointTypeFixedInSystem');
fixedPt.FixedPoint.AssignCartesian(.005,0,.005);

%Create a new Angle
AngFactory = vgtSat.Angles.Factory;
betwVect = AngFactory.Create('SatEarth2Y','Displacement Vector to Sat Body Y','eCrdnAngleTypeBetweenVectors');
betwVect.FromVector.SetVector(Sat2EarthCenter);
betwVect.ToVector.SetVector(bodyYSat); 

%Create a new Axes
AxesFactory = vgtSat.Axes.Factory;
AlignConstain = AxesFactory.Create('AlignConstrain','Aligned to displacement vector and constrained to Body Y','eCrdnAxesTypeAlignedAndConstrained');
AlignConstain.AlignmentReferenceVector.SetVector(Sat2EarthCenter);
AlignConstain.AlignmentDirection.AssignXYZ(1,0,0);
AlignConstain.ConstraintReferenceVector.SetVector(bodyYSat);
AlignConstain.constraintDirection.AssignXYZ(0,0,1);

%Create a new System
SysFactory = vgtSat.Systems.Factory;
assemSys = SysFactory.Create('FixedPtSystem','System with origin at the new point','eCrdnSystemTypeAssembled');
assemSys.OriginPoint.SetPoint(fixedPt);
assemSys.ReferenceAxes.SetAxes(bodyAxes);

%Create a new Plane
PlaneFactory = vgtSat.Planes.Factory;
yzQuad = PlaneFactory.Create('YZQuad','YZ Quadrant','eCrdnPlaneTypeQuadrant');
yzQuad.ReferenceSystem.SetSystem(icrf);
yzQuad.Quadrant = 'eCrdnQuadrantYZ';

%--------------------------
%****CALC TOOL EXAMPLES****
%--------------------------

%Create a new Vector Magnitude Scalar
calcFactory = vgtSat.CalcScalars.Factory;
displScalar = calcFactory.CreateCalcScalarVectorMagnitude('VectorDisplacement','Vector Magnitude of Displacement Vector');
displScalar.InputVector = Sat2EarthCenter;

%Create a Data Element Scalar
trueAnom = calcFactory.Create('TrueAnomaly','','eCrdnCalcScalarTypeDataElement');
trueAnom.SetWithGroup('Classical Elements','ICRF','True Anomaly');

%Create a new Condition
angle = root.ConversionUtility.NewQuantity('AngleUnit','deg',3.14);
condFactory = vgtSat.Conditions.Factory;
scaleBound = condFactory.Create('BelowMax','Valid for displacement','eCrdnConditionTypeScalarBounds');
scaleBound.Scalar = trueAnom;
scaleBound.Operation = 'eCrdnConditionThresholdOptionBelowMax';
scaleBound.SetMaximum(angle);

%Create a new Parameter Set
paraFactory = vgtSat.ParameterSets.Factory;
paraSet = paraFactory.Create('attitudeICRF','Attitude Set','eCrdnParameterSetTypeAttitude');
paraSet.Axes = bodyAxes; 
paraSet.ReferenceAxes = icrfAxes;

%--------------------------
%****TIME TOOL EXAMPLES****
%--------------------------

%Get times from defined Time Instant
satStart= vgtSat.Events.Item('AvailabilityStartTime');
start = satStart.FindOccurrence.Epoch;

satStop= vgtSat.Events.Item('AvailabilityStopTime');
stop = satStop.FindOccurrence.Epoch;
interval = {start 540 600 stop}';

%Create a new Time Instant
timeInstFactory = vgtSat.Events.Factory;
timeEpoch = timeInstFactory.CreateEventEpoch('FixedTime','Fixed Epoch Time');
timeEpoch.Epoch = 3600;

%Create a new Time Interval
timeIntFactory = vgtSat.EventIntervals.Factory;
timeInterval = timeIntFactory.CreateEventIntervalFixed('TimeInterval','Fixed time interval');
timeInterval.SetInterval(60,120);

%Create a new Interval List 
timeListFactory = vgtSat.EventIntervalLists.Factory;
Custom = timeListFactory.Create('Custom','','eCrdnEventIntervalListTypeFixed');
Custom.SetIntervals(interval);

%Create a new Collection of Interval List
timeCollListFactory = vgtSat.EventIntervalCollections.Factory;
timeColl = timeCollListFactory.CreateEventIntervalCollectionLighting('LightingList','Collection of lighting intervals');
timeColl.UseObjectEclipsingBodies = true;
timeColl.Location = centerPtSat;

%Create a new Time Array
timeArrayFactory = vgtSat.EventArrays.Factory;
timeArray = timeArrayFactory.CreateEventArrayStartStopTimes('StartTimes','Start Times of Custom Intervals');
timeArray.ReferenceIntervals = Custom;
timeArray.StartStopOption = 'eCrdnStartStopOptionCountStartOnly';

msgbox('Components Created!');