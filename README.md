# ocd_bdd_arbitration_rsfmri
Preprocessing and analysis scripts for the manuscript "Neurocircuit dynamics of arbitration between decision-making strategies across obsessive-compulsive and related disorders".

Author list:
Darsol Seok, Reza Tadayonnejad, Wan-wa Wong, Joseph O'Neill, Jeff Cockburn, Ausaf A. Bari, John P. O’Doherty and Jamie D. Feusner

Scripts in 01_preprocessing cover all steps from raw imaging data to deriving estimates of dynamic effective connectivity (DEC).
Scripts in 02_analysis cover all analyses of DEC. 
References for all packages utilized are cited in the manuscript.

01_preprocessing/
  01_fmriprep/
    Preprocessing raw imaging data using FMRIPREP.
  02_xcp-rest/
    Applying additional image preprocessing steps, including regression of nuisance time series, using XCP-engine.
  03_rsHRF/
    Performing blind-source deconvolution using the HRF package (an SPM extension).
  04_dec/
    Computing estiamtes of dynamic effective connectivity using Granger causality.

02_analysis/
  00_demographic_analysis.Rmd
    Performing statistical tests of demographic variables (age, sex and psychiatric symptom severity scores)
  01_group_differences.Rmd
    Performing statistical tests of group differences between OCD/BDD groups and their respective healthy controls.
  02_symptom_associations.Rmd
    Performing statistical tests of continuous association between symptom severity and DEC.
