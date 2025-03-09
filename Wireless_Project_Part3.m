clc; clear; close all;

% Define SNR values (adjust range based on your paper)
SNR = 0:2:30;  % Signal-to-Noise Ratio (dB)

% Execution time modeling (assumed trends based on paper)
STLS_Time = 0.25 + 1.5 * exp(-SNR / 6);      % Exponential decay model
Circulant_Time = 0.2 + 1.2 * exp(-SNR / 8);  % Slightly faster convergence

% Plot Execution Time vs. SNR
figure;
plot(SNR, STLS_Time, '-sr', 'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', 'r');
hold on;
plot(SNR, Circulant_Time, '-ob', 'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', 'w');
hold off;

% Add labels and title
xlabel('SNR (dB)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Average Execution Time (s)', 'FontSize', 12, 'FontWeight', 'bold');
title('Execution Time Comparison: STLS vs. Circulant', 'FontSize', 14, 'FontWeight', 'bold');

% Add a legend
legend({'STLS Method', 'Circulant Method'}, 'Location', 'NorthEast', 'FontSize', 10);

% Enable grid for better visualization
grid on;
