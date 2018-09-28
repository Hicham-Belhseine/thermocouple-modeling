function [] = Thermocouple_Modeling(filename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Program Description 
% This executive function calls our UDF to identify parameters for each
% trial in the data sets given.
%
% Function Call
% ProjectM4_Exec_011_17()
%
% Input Arguments
% filename - Name of the testing file, example: "heating_data.csv"
%
% Output Arguments
% None
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ____________________
%% INITIALIZATION

thermocouple_data = csvread(filename);
times = thermocouple_data(:, 1);
temps = thermocouple_data(:, 2);

[tL, tH, tS, tau, model, temps] = Thermocouple_Characteristics(times, temps);

%% _____________
%% DATA OUTPUT

% Figure that will be saved
fig = figure('visible', 'off');

% Graph formatting
title("Thermocouple Response: Temperature vs Elapsed Time")
xlabel('Elapsed Time [s]')
ylabel('Temperature [°F]')
grid on; hold on;
xlim([0 floor(times(end))])

% Plotting thermocouple data and model and save it
plot(times, temps, 'Color', [.15 .3 1])
plot(times, model, 'Color', [1 .2 .18], 'LineWidth', 1.2)


% Legend
legend('Input Data', 'Modeled Data', 'Location', 'northwest')

% Save plot
saveas(fig, 'output.pdf')

% Detailing thermocouple characteristics
fprintf('\nTESTING RESULTS\n');
fprintf('----------------------------\n');
fprintf("Tau:       %7.3f  s\n", tau);
fprintf("Temp Low:  %7.3f °F\n", tL);
fprintf("Temp High: %7.3f °F\n\n", tH);

end