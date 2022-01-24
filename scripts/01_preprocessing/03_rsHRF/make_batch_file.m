function [] = make_batch_file(batchfile, batchoutpath, img, tr, mask, outdir, nuisance, x, y, z, rad)
% modify the default batch file and save

% read batchfile
matlabbatch = importdata(batchfile);

% edit parameters
matlabbatch{1}.spm.tools.rsHRF.vox_rsHRF.images{1} = img;
matlabbatch{1}.spm.tools.rsHRF.vox_rsHRF.HRFE.TR = tr;
matlabbatch{1}.spm.tools.rsHRF.vox_rsHRF.mask{1} = mask;
matlabbatch{1}.spm.tools.rsHRF.vox_rsHRF.outdir{1} = outdir;
matlabbatch{1}.spm.tools.rsHRF.vox_rsHRF.Denoising.generic{1}.multi_reg{1} = nuisance;
% matlabbatch{1}.spm.tools.rsHRF.ROI_rsHRF.genericROI{1}.ROI = [x, y, z, rad];

% save
save(batchoutpath, 'matlabbatch')

end
