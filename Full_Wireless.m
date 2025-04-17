%% Project: Secure Communication via Relative Calibration and Key Generation
clc; clear; close all;

%% Parameters
N = 64;
SNR_range = -30:5:30; 
runs = length(SNR_range);

% Result holders
corr_before = zeros(1, runs);
corr_stls = zeros(1, runs);
corr_circ = zeros(1, runs);
key_match_stls = zeros(1, runs);
key_match_circ = zeros(1, runs);
exec_time_stls = zeros(1, runs);
exec_time_circ = zeros(1, runs);

% Final keys
final_key_circ_bin = '';
final_key_circ_alpha = '';

%% Loop over SNR values
for idx = 1:runs
    SNR_dB = SNR_range(idx);
    SNR = 10^(SNR_dB/10);

    % --- Channel and Hardware Filters ---
    C = (randn(1,N) + 1i*randn(1,N))/sqrt(2);
    tA = fir1(10, 0.4); rB = fir1(12, 0.5);
    tB = fir1(14, 0.3); rA = fir1(16, 0.6);
    G = conv(conv(tA, C), rB);
    H = conv(conv(tB, C), rA);
    noiseG = (randn(1,length(G)) + 1i*randn(1,length(G))) / sqrt(2*SNR);
    noiseH = (randn(1,length(H)) + 1i*randn(1,length(H))) / sqrt(2*SNR);
    G_noisy = G + noiseG;
    H_noisy = H + noiseH;

    %% Match lengths for correlation
    min_len = min(length(G_noisy), length(H_noisy));
    G_noisy = G_noisy(:)'; H_noisy = H_noisy(:)';
    G_noisy = G_noisy(1:min_len);
    H_noisy = H_noisy(1:min_len);
    corr_before(idx) = abs(corr(G_noisy', H_noisy'));

    %% STLS Deconvolution
    tic;
    L = min_len;
    fun = @(p) norm(G_noisy(1:L)' - toeplitz(H_noisy(1:L), [H_noisy(1), zeros(1, L-1)]) * p)^2;
    p0 = ones(L, 1);
    options = optimoptions('fminunc','Display','off','Algorithm','quasi-newton');
    p_stls = fminunc(fun, p0, options);
    H_stls = toeplitz(H_noisy(1:L), [H_noisy(1), zeros(1, L-1)]);
    G_stls = zeros(1, min_len);
    temp_stls = (H_stls * p_stls)';
    copy_len = min(length(temp_stls), min_len);
    G_stls(1:copy_len) = temp_stls(1:copy_len);
    exec_time_stls(idx) = toc;
    corr_stls(idx) = abs(corr(G_noisy', G_stls'));

    %% Circulant Deconvolution
    tic;
    H_circ = zeros(min_len, L);
    h_padded = [H_noisy(1:L), zeros(1, min_len-L)];
    for i = 1:L
        H_circ(:, i) = circshift(h_padded', i-1);
    end
    p_circ = pinv(H_circ) * G_noisy';
    G_circ = zeros(1, min_len);
    temp_circ = (H_circ * p_circ)';
    copy_len = min(length(temp_circ), min_len);
    G_circ(1:copy_len) = temp_circ(1:copy_len);
    exec_time_circ(idx) = toc;
    corr_circ(idx) = abs(corr(G_noisy', G_circ'));

    %% Key Generation (Binary Match)
    k1 = real(G_noisy) > 0;
    k_stls = real(G_stls) > 0;
    k_circ = real(G_circ) > 0;
    key_match_stls(idx) = sum(k1 == k_stls) / length(k1);
    key_match_circ(idx) = sum(k1 == k_circ) / length(k1);

    %% Save final keys for last SNR point (30 dB)
    if idx == runs
        key_str = num2str(k_circ);
        key_str(key_str == ' ') = '';
        final_key_circ_bin = key_str;

        keyspace = ['A':'Z', 'a':'z', '0':'9'];
        x = abs(real(G_circ)); 
        x = x / max(x);
        if length(x) < 8
            x = [x, zeros(1, 8-length(x))];
        end
        x = x(1:8);
        indices = ceil(x * length(keyspace));
        indices(indices < 1) = 1;
        indices(indices > length(keyspace)) = length(keyspace);
        final_key_circ_alpha = char(keyspace(indices));
    end
end
disp('---------------------------------------------');
disp(['Generated Binary Key (Circulant):']);
disp(final_key_circ_bin);
disp('Generated 8-character Key (Alphanumeric, Circulant):');
disp(final_key_circ_alpha);
disp('---------------------------------------------');
fprintf('\nSample Result at SNR = %d dB\n', SNR_range(end));
fprintf('Correlation Before Calibration: %.4f\n', corr_before(end));
fprintf('Correlation After STLS: %.4f\n', corr_stls(end));
fprintf('Correlation After Circulant: %.4f\n', corr_circ(end));
fprintf('Key Match STLS: %.2f%%\n', key_match_stls(end)*100);
fprintf('Key Match Circulant: %.2f%%\n', key_match_circ(end)*100);

%% --- Plot 1: Correlation vs SNR ---
figure;
plot(SNR_range, corr_before, 'k--', 'LineWidth', 2); hold on;
plot(SNR_range, corr_stls, 'g-s', 'LineWidth', 2);
plot(SNR_range, corr_circ, 'b-d', 'LineWidth', 2);
xlabel('SNR (dB)', 'FontWeight', 'bold'); ylabel('Correlation Coefficient', 'FontWeight', 'bold');
legend('Before Calibration','STLS','Circulant','Location','southeast');
title('SNR vs Correlation Coefficient');
grid on;
set(gca, 'FontSize', 12, 'LineWidth', 1.5, 'Box', 'on'); 

%% --- Plot 2: % Improvement vs SNR ---
improve_stls = ((corr_stls - corr_before) ./ corr_before) * 100;
improve_circ = ((corr_circ - corr_before) ./ corr_before) * 100;

figure;
plot(SNR_range, improve_stls, 'g-s', 'LineWidth', 2); hold on;
plot(SNR_range, improve_circ, 'b-d', 'LineWidth', 2);
xlabel('SNR (dB)', 'FontWeight', 'bold'); ylabel('Improvement (%)', 'FontWeight', 'bold');
legend('STLS','Circulant','Location','southeast');
title('SNR vs % Improvement in Correlation');
grid on;
yticks = get(gca, 'YTick');
set(gca, 'YTickLabel', yticks / 100, 'FontSize', 12, 'LineWidth', 1.5, 'Box', 'on');

%% --- Plot 3: Execution Time vs SNR (Bar Graph) ---
figure;
plot(SNR_range, exec_time_stls*1000, 'g-s', 'LineWidth', 2); hold on;
plot(SNR_range, exec_time_circ*1000, 'b-d', 'LineWidth', 2);
xlabel('SNR (dB)', 'FontWeight', 'bold'); ylabel('Execution Time (ms)', 'FontWeight', 'bold');
legend('STLS','Circulant','Location','northwest');
title('Execution Time vs SNR');
grid on;
set(gca, 'FontSize', 12, 'LineWidth', 1.5, 'Box', 'on');
