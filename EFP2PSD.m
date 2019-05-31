function EFP2PSD


if matlabpool('size')==0
    % 4-5 seems to be optimal for grinding EFP data
    matlabpool 6
end

freq = 0:0.1:100;
load EFP
N = size(EFP, 1); %#ok<*NODEF>
PSD = zeros(N, length(freq));

parfor i=1:N
    dt = EFP(i, :);  %#ok<*PFIIN>

	a3 = msspectrum(spectrum.periodogram, dt(40001:end)-mean(dt(40001:end)), ...
		'Fs', 40000, ...
		'SpectrumType', 'twosided', ...
		'FreqPoints', 'User Defined', ...
		'FrequencyVector', freq);
	
	PSD(i,:) = a3.data;  %#ok<PFOUS>
end

save PSD1000ms freq PSD
		
