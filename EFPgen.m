function EFPgen


if matlabpool('size')==0
    % 4-5 seems to be optimal for grinding EFP data
    matlabpool 8
end


JORDANROOT = './';
datadir = [JORDANROOT 'data/efs'];


vals = dlmread('FRBGamm.val', ' ', 1, 0);
vals(:,end) = []; % For some reason a column of zeros is added at the end
[N M] = size(vals);
fprintf(1, 'Processing %d datasets\n', N);

% Format string
fstr = char(zeros(1,2*M));
fstr(1:2:end) = '%';
fstr(2:2:end) = 'd';

tmz = 0:0.025:2000;
EFP = zeros(N, length(tmz));

for j=1:N/128
parfor i=((j-1)*128+1):((j)*128)
	idstr = sprintf(fstr, vals(i, :));

	fn = [datadir '/en*_' idstr '.dat.gz'];
    [~, dt, ~, ~] = efs(fn);

    dt = [dt; zeros(length(tmz)-length(dt), 1)];
    EFP(i, :) = dt; %#ok<PFOUS>
end
	save -v7.3
end

tm=tmz;
save -v7.3 EFP tm EFP
		
function [tm dt fail failmsg] = efs(fng)
fail = false;
failmsg = 'well done';
dt = 0; tm = 0;

path = fileparts(fng);
fnl = dir(fng);

if isempty(fnl)
	fail = true;
	failmsg = 'files not found';
	return
end

fn = [path '/' fnl(1).name];
try
	EF = loadgz(fn);
	dt = sum(EF(:,[3 5 7 9 11]),2);
	tm  = EF(:,1);
catch crap
	failmsg = crap.message;
	fail = true;
	return
end

for i=2:length(fnl)
	fn = [path '/' fnl(i).name];
	try
		EF = loadgz(fn);
	catch crap
		failmsg = crap.message;
		fail = true;
		return
	end
	try
		dt = dt + sum(EF(:,[3 5 7 9 11]),2);
	catch crap
		failmsg = crap.message;
		fail = true;
		return
	end
end

function EF = loadgz(fn)
system(['gunzip ' fn]);
EF = load(fn(1:end-3));
system(['gzip ' fn(1:end-3)]);
