clc
clear all
close all

N = input('Enter the number of elements in vector s: ');

elements = cell(1, N);
for i = 1:N
    elements{i} = char(96 + i);
end

circulant_reuse = N * ones(1, N);   % Circulant reuse factor
toeplitz_reuse = min(1:N, N:-1:1);  % Toeplitz reuse factor

figure;
plot(1:N, toeplitz_reuse, '-ob', 'LineWidth', 2, 'MarkerSize', 8);
hold on;
plot(1:N, circulant_reuse, '-sr', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'r'); 
hold off;

xticks(1:N);
xticklabels(elements);
xlabel('Elements of vector "s"');
ylabel('Number of times information is re-used');
legend({'Toeplitz matrix', 'Circulant matrix'}, 'Location', 'northwest');
title('Comparison of the Toeplitz and Circulant matrices');
grid on;
set(gca, 'FontSize', 12, 'FontWeight', 'bold');
