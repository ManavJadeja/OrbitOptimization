%%% SENSOR RANGE

% Formatting Stuff
format bank
Re = 6378;              % Radius of the Earth (km)
H = 200:25:600;         % Varing Altitudes (500 km to 1000 km)

% Computing Range (uses the paper pinned on the Discord Server)
sum = bsxfun(@plus, Re, H);
rho = asin(Re./sum);
lambda_min = acos(Re./sum);
nadir_min = atan((sin(rho).*sin(lambda_min))./(1+sin(rho).*cos(lambda_min)));
range = (Re.*sin(lambda_min)./sin(nadir_min))';

% Outputs
disp(" Altitude (km) and Range (km)")
for i = 1:length(H)
    string = [H(i), range(i)];
    disp(string)
end
disp("DONE")
