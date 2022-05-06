accessAER = access.DataProviders.Item('AER Data').Group.Item('BodyFixed').Exec(scenario.StartTime, scenario.StopTime, 60);
AERTimes = cell2mat(accessAER.Interval.Item(cast(0, 'int32')).DataSets.GetDataSetByName('Time').GetValues);
Az = cell2mat(accessAER.Interval.Item(cast(0, 'int32')).DataSets.GetDataSetByName('Azimuth').GetValues);
El = cell2mat(accessAER.Interval.Item(cast(0, 'int32')).DataSets.GetDataSetByName('Elevation').GetValues);
for i = 1:1:accessAER.Interval.Count-1
    AERTimes = [AERTimes; cell2mat(accessAER.Interval.Item(cast(i, 'int32')).DataSets.GetDataSetByName('Time').GetValues)];
    Az = [Az; cell2mat(accessAER.Interval.Item(cast(i, 'int32')).DataSets.GetDataSetByName('Azimuth').GetValues)];
    El = [El; cell2mat(accessAER.Interval.Item(cast(i, 'int32')).DataSets.GetDataSetByName('Elevation').GetValues)];
end
