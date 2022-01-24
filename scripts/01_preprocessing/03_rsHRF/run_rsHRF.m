function [] = run_rsHRF(batchfile)
% run the batch file using SPM
spm('defaults','fmri');
spm_jobman('initcfg');

matlabbatch = importdata(batchfile);

disp('Running matlabbatch')
spm_jobman('run',matlabbatch);

end
