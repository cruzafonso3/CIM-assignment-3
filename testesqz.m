
% M.EEC045 - CODIFICACAO DE INFORMACAO MULTIMEDIA
%
% first home assignment (audio part)
%
% due date: March 29, 2026
%
% Anibal Ferreira

% AUDIO PART

[x,FS]=audioread('sting22.wav');
% [x,FS,NBITS]=wavread('sting22.wav'); % old Matlab versions
NBITS=16;
%sound(x,FS,NBITS); % NOTE: x values are already in the range [-1, 1]
samples=[0:length(x)-1];
%figure(1)
%plot(samples/FS, x);
%xlabel('Time (s)');
%ylabel('Amplitude');
%title('sting22.wav');

% insert code here

N_values = [2 4 6 8 10 12 14 16];
SNR_dB = zeros(size(N_values));



for k = 1:length(N_values)
	N = N_values(k);
	L = 2^N;
	delta = 2/L; % quantization step for range [-1, 1]

	% Uniform quantizer (mid-rise) in [-1, 1]
	q_index = floor((x + 1)/delta);
	q_index = max(min(q_index, L - 1), 0);
	x_rec = -1 + (q_index + 0.5)*delta;

	e = x - x_rec; % quantization error

	signal_power = sum(x(:).^2);
	noise_power = sum(e(:).^2);
	SNR_dB(k) = 10*log10(signal_power/noise_power);

	fprintf('N = %2d bits -> SNR = %6.2f dB\n', N, SNR_dB(k));

	%Optional listening examples:
	%sound(x_rec, FS, NBITS);
	%pause(length(x)/FS + 0.5);
	%sound(e, FS, NBITS);
	%pause(length(x)/FS + 0.5);


end

% First-order model SNR_dB = a*N + b
p = polyfit(N_values, SNR_dB, 1);
SNR_fit = polyval(p, N_values);

figure(4)
plot(N_values, SNR_dB, 'o-', 'LineWidth', 1.5);
hold on;
plot(N_values, SNR_fit, '--', 'LineWidth', 1.5);
grid on;
xlabel('N (bits)');
ylabel('SNR (dB)');
title('SNR vs Number of Bits (Audio Re-quantization)');
legend('Measured SNR', sprintf('Linear fit: SNR = %.3fN + %.3f', p(1), p(2)), 'Location', 'northwest');
hold off;

fprintf('Linear model (1st order): SNR_dB = %.6f * N + %.6f\n', p(1), p(2));



% IMAGE PART

% reads and displays image
A=imread('lena512.bmp');
figure(2)
imshow(A,[0 255]); % displays original image
A=single(A)/255.0; % converts to float and normalizes [0, 1.0]
title('lena512.bmp');


% insert code here
Ar=A; % this is temporary, to be replaced by the new code

Ar=uint8(Ar*255.0); % converts to "uint" format
figure(3)
imshow(Ar,[0 255]); % displays modified image
title('modified Lena');

