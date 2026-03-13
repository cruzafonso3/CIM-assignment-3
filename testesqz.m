
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
sound(x,FS,NBITS); % NOTE: x values are already in the range [-1, 1]
samples=[0:length(x)-1];
figure(1)
plot(samples/FS, x);
xlabel('Time (s)');
ylabel('Amplitude');
title('sting22.wav');

% insert code here



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

