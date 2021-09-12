What even do I put here

Note: This is a work in progress, things labelled 'ND' are 'Not Done'


Thought Process:
1) Satellite Payload Data
	-Figure out how much data needs to be uplinked and downlinked
	-Analyze payload and spacecraft sensors (get appropriate number of bytes)
	-Get the maximum data (I did it per orbit but per year is needed)
2) Scenario in STK
	-Use STK to create a scenario (year long)
	-Add ground station and sensor (with appropriate constraints)
	-Create a satellite(s) and compute access (year long)
3) Data Analysis
	-Store access time durations (use histogram to see distribution)
	-Add up access times to get total duration (seconds/year)
	-Use total data and total time to get data rate (use safety factor >= 2)
		-Confirm data rate is within spacecraft capabilities
4) Orbit Optimization (ND)
	-Check for required total access time across...
		-Angle of inclination and semimajor axis
	-Lower semimajor axis and get appropriate range for angle of inclination
	-Repeat for all of LEO (get a whole region of values that meet requirements)
		-Lower semimajor axis is cheaper with range of acceptable orbits there
5) Spacecraft Design (ND)
	-With all this, figure out the rest of the spacecraft requirements
		-Power Budget, Thermal, Link Budget, Lifetime Analysis, etc
	-Some other things to do as well (based entirely on payload)
		-Spacecraft Bus and Configuration, Structure and Vibration Testing
		-Command+Data Handling, Flight Software, Onboard Computer, etc


Synopsis of Code:
0) File name
	-Purpose 1
	-Purpose 2
1) basicInfo.m
	-Clean up
	-Scenario Info (name, start time, stop time, etc)
	-Facility Info (name, location (coordinates), etc)
2) startSTK.m
	-Open STK from MATLAB
	-Create a scenario and implement properties (defined in basicInfo.m)
3) addFacility.m
	-Create a facility and implement properties (defined in basicInfo.m)
4) addSensor.m
	-Create a sensor on facility (represents ground station)
	-Modify properties (range, elevation angle, graphics, etc)
5) addSatellite.m
	-Create a satellite and implement properties (semimajor axis, eccentricity)
		-Semimajor Axis, Eccentricity, Inclination, Perigee, Ascending Node, True Anomaly
	-Propagate Orbit and Rewind Scenario (modify graphics)
6) getAccess.m
	-Compute access between objects (satellite to sensor)
	-Get computed access times (date format here)
7) dataAnalysis.m
	-Payload and Spacecraft Data (experiment and status)
		-Data from clock, payload sensors, and spacecraft status (monitoring health)
	-Return total data (per orbit > easy to get per year from here (i think))
8) doAccessAnalysis.m
	-Get access durations (from access data) and perform analysis
		-Histogram of access durations (know variation of durations)
	-Sum to get total access time in a year (safety factor for contingencies)
	-Compute data rate with total data / total time (both are over a year)
		-Confirm that this is within communication system capabilities


How to Run:
1) basicInfo.m
	-Has information for optimization
		-Scenario: Start and Stop times
		-Facility+Sensor: Location, range, and angle
		-Satellite: Orbit parameters (ranges)
		-Access: required duration (predefined) and safety margin
2) startSTK.m
	-Starts STK and loads scenario information
3) addEverything.m
	-Add and modify singular objects (facility and sensor)
	-Satellites added, modified, tested, color-coded
		-Adds a satellite with parameters (one by one)
		-Propogates and performs access computation
		-Color coded graphics based on access requirements
	
About:
Written by me over the summer. 
Things I don't know: (so don't ask)
 -How accurate this is > can't even tell you if this will work
 -Validity of parameters used > don't know whether sensor information is right
 	-Number, accuracy, error, data type, etc etc (everything is basically a guess)
 -Long-term planning > don't know how to implement lifetime analysis (just round up lol)
Final Note: (and warnings)
 -I AM NOT RESPONSIBLE FOR YOUR MISSION FAILING IF YOU BASE IT ON MY CODE!
 -I WOULD ENCOURAGE YOU TO FIX THIS TO MEET YOUR NEEDS OR NOT USE IT AT ALL!
Resources Used:
 1) AGI > STK MATLAB Code Snippets, Customer Support (email)
 2) MATLAB > Help pages and sample code (also youtube)
 3) SMAD (book) > Idea to use data to find optimal orbit (meet requirements within error margin)
 	> Other mission parameters follow (based on orbit, payload (data), and computer needs)


