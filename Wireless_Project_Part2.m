% Clear workspace and close all figures
clc; clear; close all;

%% 1st Graph: Percentage Improvement of Circulant Over STLS
SNR = -30:1:30;  % Define SNR range

% Sample improvement data (modify if needed)
Improvement = 5 * exp(-SNR / 10);  

% Plot improvement graph
figure;
plot(SNR, Improvement, '-om', 'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', 'w');  
xlabel('SNR (dB)', 'FontSize', 12, 'FontWeight', 'bold');  
ylabel('Percentage Improvement (%)', 'FontSize', 12, 'FontWeight', 'bold');  
title('Percentage Improvement of Circulant Over STLS', 'FontSize', 14, 'FontWeight', 'bold');  
legend({'Improvement with Circulant'}, 'Location', 'NorthEast', 'FontSize', 10);  
grid on;
set(gca, 'FontSize', 12, 'FontWeight', 'bold');  


%% 2nd Graph: Comparison of STLS and Circulant
% Generate data for STLS and Circulant (Example Gaussian-like curve)
STLS = 65 * exp(-((SNR)/8).^2);   
Circulant = 60 * exp(-((SNR)/8).^2);  

% Plot STLS
figure;
hold on;
plot(SNR, STLS, '-sr', 'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', 'r');  

% Plot Circulant
plot(SNR, Circulant, '-ob', 'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', 'w');  

% Add Reference Line
yline(0, 'k', 'LineWidth', 2);  

% Labels & Title
xlabel('SNR (dB)', 'FontSize', 12, 'FontWeight', 'bold');  
ylabel('Percentage Increase (%)', 'FontSize', 12, 'FontWeight', 'bold');  
title('Comparison of STLS and Circulant', 'FontSize', 14, 'FontWeight', 'bold');  

% Grid & Legend
grid on;
legend({'STLS', 'Circulant', 'Reference Line'}, 'Location', 'NorthWest', 'FontSize', 10);  

% Formatting
set(gca, 'FontSize', 12, 'FontWeight', 'bold');  
hold off;


%% 3rd Graph: Correlation Coefficient vs. SNR
% Generate data (sigmoid-like function)
Before_Calibration = 0.4 + 0.6 * (1 - exp(-SNR / 8)); 
STLS_Calibration = 0.45 + 0.55 * (1 - exp(-SNR / 10));
Circulant_Calibration = 0.47 + 0.53 * (1 - exp(-SNR / 12));

% Plot the data
figure;
hold on;
plot(SNR, Before_Calibration, '--k', 'LineWidth', 2);  
plot(SNR, STLS_Calibration, '-b', 'LineWidth', 2);  
plot(SNR, Circulant_Calibration, '-r', 'LineWidth', 2);  

% Labels & Title
xlabel('SNR (dB)', 'FontSize', 12, 'FontWeight', 'bold');  
ylabel('Correlation Coefficient', 'FontSize', 12, 'FontWeight', 'bold');  
title('Comparison of STLS and Circulant: SNR vs Correlation', 'FontSize', 14, 'FontWeight', 'bold');  

% Grid & Legend
grid on;
legend({'Before Calibration', 'STLS Calibration', 'Circulant Calibration'}, 'Location', 'SouthEast', 'FontSize', 10);  

% Formatting
set(gca, 'FontSize', 12, 'FontWeight', 'bold');  
hold off;
