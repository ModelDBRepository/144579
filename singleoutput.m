function singleoutput


freq = 0:0.1:100;
load PSD1000ms
% load 'D:\Stuff\Dropbox\Papers\Parametric computation and TC oscillations\Fig 5&6 - effects analysis\PSD'

N = length(PSD);
gindx = 30<=freq & freq<=80;
gfreq = freq(gindx);

gStrength    = zeros(N, 1);
gPeakF    = zeros(N, 1);


designfile = 'FRBGamma.des';
for i=1:N
	G = PSD(i, gindx);
    gStrength(i) = sum(G);
	[~, x] = max(G);
	gPeakF(i) = gfreq(x);
end

gStrength(gStrength>1e6) = mean(gStrength);
save gStrength.csv gStrength -ASCII
save gPeakF.csv gPeakF -ASCII

titlestr   = 'Peak Frequency';
figure
hist(gPeakF)
xlabel('Hz');
title('Frequency distribution')

% saveas(gcf, [titlestr ' - qqplot.png']);
ND(designfile, gPeakF, [titlestr ' - effects'])

titlestr   = '\Gamma power';
ND(designfile, gStrength, titlestr)

title(titlestr)
% saveas(gcf, [titlestr ' - qqplot.png']);

set(findall(0, '-property', 'fontweight'), ...
    'fontweight', 'bold', ...
    'fontsize', 14)
set(get(0, 'children'), 'color', 'white')

function cyclecolour(lh, lasth, fh)
% Cycle the colour of a line to the next one, useful for adding lines to
% plots and cycling the color.

if nargin<3, fh = gcf; end

if isempty(lasth), return, end

c = get(lasth, 'markeredgecolor');

cm = get(fh, 'DefaultAxesColorOrder');

indx = find(c(1)==cm(:,1) & c(2)==cm(:,2) & c(3)==cm(:,3));

indx = mod(indx, length(cm)) + 1;

set(lh, 'markeredgecolor', cm(indx,:))
function [Nfact UserNames defconts desarray] = readdesign(dfname)
df = fopen(dfname, 'r');

Nfact = fscanf(df, '%d factors');

while true
	l = fgetl(df);
	if strcmp(l, 'User''s names:')==1
		break
	end
end
UserNames = textscan(df, '%s', Nfact);
UserNames = UserNames{1};


dcstr = 'defining contrasts:';
ndcstr = length(dcstr);
while true
	l = fgetl(df);
	if length(l)<ndcstr, continue, end
	if strcmp(l(end-ndcstr+1:end), dcstr)==1
		Ndef = sscanf(l, '%d');
		break
	end
end
crap = textscan(df, '%s', Ndef);
defconts = cell(Ndef, 1);
for i=1:Ndef
	s = crap{1}{i};
	defconts{i} = s(1:2:end);
end

fgetl(df);
fgetl(df);
desarray = textscan(df, '%d');%, 2^(Nfact-Ndef)*Nfact);
desarray = reshape(desarray{1}, Nfact, 2^(Nfact-Ndef))';

fclose(df);
