%%% ACCESS
% Compute access between objects (satellite > facility)
access = satellite.GetAccessToObject(sensor);
access.ComputeAccess();

%Get computed access intervals
intervalCollection = access.ComputedAccessIntervalTimes;
computedIntervals = intervalCollection.ToArray(0, -1);
access.SpecifyAccessIntervals(computedIntervals);
disp(computedIntervals)
disp("Access Computed")