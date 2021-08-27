%%% DOUBLE PRECISION ERROR

limit = 1e8;
max_error = 0;
index = 0;
for i = -limit:1:-limit*0.9
    error = eps(i);
    if (error > max_error)
        max_error = error;
        index = i;
    end
end

disp("The number with max error")
disp(index)
disp("The error of that number")
disp(max_error)
