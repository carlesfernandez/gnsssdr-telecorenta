% This script plots the acquisition grid obtained by GNSS-SDR
% in MATLAB/Octave without using the GUI interface.
%
% Requires previous processing with the following lines
% in the GNSS-SDR configuration file:
% Acquisition_1C.dump=true 
% Acquisition_1C.dump_filename=acq_dump
% Acquisition_1C.dump_channel=0
%
% You can call it by doing:
% 
% docker run -it --rm -v $PWD:/home carlesfernandez/gnsssdr-telecorenta octave --no-gui acquisition_grid.m
%
% Get a nice PDF with the result:
% docker run -it --rm -v $PWD:/home carlesfernandez/gnsssdr-telecorenta epspdf acq_result.eps acq_result.pdf
%
% SPDX-FileCopyrightText: 2024, Carles Fernandez-Prades <carles.fernandez@cttc.es>
% SPDX-License-Identifier: MIT

load('./acq_dump_G_1C_ch_0_9_sat_22.mat');  % <-- REPLACE THIS FILE WITH YOU ACTUAL FILENAME

f = int32(-doppler_max):int32(doppler_step):int32(doppler_max)-int32(doppler_step);
tau = linspace(0, 1023, size(acq_grid, 1));

hf = figure('visible', 'off');   % <-- REPLACE with hf = figure; IF YOU ARE IN THE GUI INTERFACE

surf(f, tau, acq_grid);

xlabel('Doppler [Hz]');
ylabel('Delay [chips]');
title(strcat('Acquisition grid for GPS sat #', num2str(PRN)));

hh = findall(hf, '-property', 'FontName');
set(hh, 'FontName', 'Times');
print(hf, 'acq_result.eps', '-depsc');
close(hf);
