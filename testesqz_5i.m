
clear; clc;

% Signal definition
samples = 0:1E5-1;
x = sin(0.22*samples);

% Quantization setup
N_values = 2:14;
SNR_dB = zeros(size(N_values));
rho_xe = zeros(size(N_values));
e_all = cell(size(N_values));

for k = 1:length(N_values)
    N = N_values(k);
    L = 2^N;
    delta = 2/L; % quantization step for range [-1, 1]

    % Uniform mid-rise quantizer over [-1, 1]
    q_index = floor((x + 1)/delta);
    q_index = max(min(q_index, L - 1), 0);
    x_rec = -1 + (q_index + 0.5)*delta;

    e = x - x_rec; % quantization error
    e_all{k} = e;

    R = corrcoef(x, e); % normalized cross-correlation at zero lag
    rho_xe(k) = R(1,2);

    signal_power = sum(x(:).^2);
    noise_power = sum(e(:).^2);
    SNR_dB(k) = 10*log10(signal_power/noise_power);

    fprintf('Sinusoid: N = %2d bits -> SNR = %7.3f dB, corr(x,e) = %+0.6f\n', N, SNR_dB(k), rho_xe(k));
end

% Item 5(iii): PDF evolution from original sinusoid to quantization error
figure(3)
tiledlayout(4,4, 'Padding', 'compact', 'TileSpacing', 'compact');

nexttile;
[H_x, X_x] = hist(x, 50);
equalize_x = 50/(max(x) - min(x));
bar(X_x, H_x/sum(H_x)*equalize_x, 0.5);
grid on;
xlabel('x[n] amplitude');
ylabel('PDF');
title('Original sinusoid');

for k = 1:length(N_values)
    nexttile;
    e_k = e_all{k};
    [H_e, X_e] = hist(e_k, 50);
    equalize_e = 50/(max(e_k) - min(e_k));
    bar(X_e, H_e/sum(H_e)*equalize_e, 0.5);
    grid on;
    xlabel('x[n] amplitude');
    ylabel('PDF');
    title(sprintf('Error PDF (N=%d)', N_values(k)));
end

% First-order model from measured values
p_meas = polyfit(N_values, SNR_dB, 1);
SNR_fit = polyval(p_meas, N_values);

% Ideal model for full-scale sinusoidal quantization
SNR_ideal = 6.02*N_values + 1.76;
p_ideal = polyfit(N_values, SNR_ideal, 1);

% Plot measured SNR, measured linear fit and ideal line
figure(1)
plot(N_values, SNR_dB, 'o-', 'LineWidth', 1.5);
hold on;
plot(N_values, SNR_fit, '--', 'LineWidth', 1.5);
plot(N_values, SNR_ideal, ':', 'LineWidth', 1.8);
grid on;
xlabel('N (bits)');
ylabel('SNR (dB)');
title('Sinusoid Quantization: Measured vs Ideal SNR');
legend('Measured SNR', ...
       sprintf('Measured fit: SNR = %.4fN + %.4f', p_meas(1), p_meas(2)), ...
       sprintf('Ideal: SNR = %.4fN + %.4f', p_ideal(1), p_ideal(2)), ...
       'Location', 'northwest');
hold off;

% Numeric comparison in the command window
fprintf('\nMeasured linear model: SNR_dB = %.6f * N + %.6f\n', p_meas(1), p_meas(2));
fprintf('Ideal linear model:    SNR_dB = %.6f * N + %.6f\n', p_ideal(1), p_ideal(2));
fprintf('Slope difference (meas - ideal): %.6f dB/bit\n', p_meas(1) - p_ideal(1));
fprintf('Intercept difference (meas - ideal): %.6f dB\n', p_meas(2) - p_ideal(2));

% Item 5(ii): correlation between original sinusoid and quantization error
figure(2)
plot(N_values, rho_xe, 'o-', 'LineWidth', 1.5);
hold on;
yline(0.10, ':', '|corr|=0.10', 'LineWidth', 1.2);
yline(-0.10, ':', 'LineWidth', 1.2);
grid on;
xlabel('N (bits)');
ylabel('Correlation coefficient');
title('corrcoef(x, e) vs Number of Bits');
legend('corr(x,e)', 'Location', 'northeast');
hold off;

% Heuristic threshold for "weak" correlation
rho_threshold = 0.10;
idx_weak = find(abs(rho_xe) < rho_threshold, 1, 'first');

if isempty(idx_weak)
    fprintf('No N in [%d,%d] reached |corr(x,e)| < %.2f.\n', N_values(1), N_values(end), rho_threshold);
else
    N_min_weak = N_values(idx_weak);
    fprintf('Minimum N with weak correlation (|corr(x,e)| < %.2f): N = %d bits\n', rho_threshold, N_min_weak);
end
