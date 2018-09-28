function [temp_low, temp_high, time_start, tau, model_data, temps] = Thermocouple_Characteristics(times, temps)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Program Description 
% This function calculates the yL, yH, tS, and tau for a given set of data
%
% Function Call
% [yL, yH, tS, tau, model, temps] = Project_M3Algorithm_011_17(times, temps)
%
% Input Arguments
% times: the set of times of the thermocouple data
% temps: the set of temperatures of the thermocouple data
%
% Output Arguments
% yL: the low temperature
% yH: the high temperature
% tS: the starting time
% tau: the time at which the temperature reaches 63.2% of the high
% temperature minus the low temperature.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ____________________
%% INITIALIZATION

%Current Initializations
tau_percent = 1-1/exp(1);         %Percent change in temp over tau seconds
span = length(temps) * .02;  %Span to smooth over (2% of the data set provides optimal resolution)

%% ____________________
%% CALCULATIONS

%smooths all of the data using lowess which is short for locally weighted 
%scatterplot smoothing which uses linear regression over a local span to
%smooth a dataset
temps_smoothed = smoothdata(temps, 'lowess', span);

%Finds the minimum and maximum temperatures of the smoothed dataset
temp_low = min(temps_smoothed);
temp_high = max(temps_smoothed);

%Find starting and ending temperatures
if temps_smoothed(1) > temps_smoothed(end)
    temp_start = temp_high;
    temp_end = temp_low;
else
    temp_start = temp_low;
    temp_end = temp_high;
end

% Calculate starting time (OLD METHOD BELOW)
% Calculates the double derivative of temperature then finds the index of
% maximum magnitude which is the starting time
temp_double_derivative = smoothdata(diff(diff(temps_smoothed)), 'lowess', span );
[~, time_start_index] = max( abs( temp_double_derivative) );
time_start = times(time_start_index);

%Finding tau
count = 1;        %Loop Counter Variable
valueFound = 0;   %Loop Control Variable
targetTau = tau_percent * (temp_end - temp_start) + temp_start; %Target temperature for tau

while valueFound == 0
    if(temps(count) > targetTau && temps(count + 1) < targetTau )
        valueFound = 1;
        ty = times(count);
    elseif(temps(count) < targetTau && temps(count + 1) > targetTau)
        valueFound = 1;
        ty = times(count);
    end
    count = count + 1; %adds one to count
end

tau = ty - time_start; %calculates the thermocouple time constant [s]

%Modeling Data
if(temp_start < temp_end)
    %Getting all input times and pairing with the modeled data (Cooling)
    start_line = ones(time_start_index-1,1)*temp_start;
    modeled_line = temp_start + (temp_end - temp_start)*(1-exp( -(times(time_start_index:end) - time_start ) / tau ));
else
    %Getting all input times and pairing with the modeled data (Heating)
    start_line = ones(time_start_index-1,1)*temp_start;
    modeled_line = temp_low + (temp_high - temp_low)*(exp( -(times(time_start_index:end) - time_start ) / tau ));
end

model_data = [start_line; modeled_line];

end

