function [] = run_dec(tspath, outpath)
% run DEC and save output

% set params
bic_smooth = 1;
ff_actual = 1;

% read data
data = dlmread(tspath);

% zscore
data_z = data;
[ntp,nroi] = size(data);
for i=1:nroi
    data_z(:,i) = zscore(data(:,i));
end

% run mvaar
[x,~] = mvaar1(data_z, bic_smooth, ff_actual);

% save outputs
csvwrite(outpath, x)

end
