# Code for paper:
Quantile-Based Randomized Kaczmarz for Corrupted Tensor Linear Systems

Authors:
Alejandra Castillo, Jamie Haddock, Iryna Hartsock, Paulina Hoyos, Lara Kassab, Alona Kryshchenko, Kamila Larripa, Deanna Needell, Shambhavi Suryanarayanan, Karamatou Yacoubou Djima


## Algorithms Implementation:
- QTRK_Algorithm.m is the implementations of QTRK in the paper
- mQTRK_Algorithm.m are the implementations of mQTRK in the paper


## User experimentation and reproducing paper's results:

### Individual experiments main script:
- ALG_experiments.m allows the user to input different parameters, run QTRK (or mQTRK) over multiple trials and generate plots 
Supporting Functions:
- ALG_trials.m runs QTRK (or mQTRK) over multiple trials
- ALG_plots.m generates error plots for (QTRK or mQTRK) after running ALG_trials.m

### Comparison experiments main script:
- mQTRK_QTRK_experiments.m allows the user to input different parameters, run QTRK and mQTRK over multiple trials, and generate plots
Supporting Functions:
- mQTRK_QTRK_trials.m runs QTRK and mQTRK (on the same problem) over multiple trials
- mQTRK_QTRK_plots.m plots generates error plots for QTRK and mQTRK after running mQTRK_QTRK_trials.m 

### Deblurring experiments main script:
- deblurring_experiments.m allows the user to input different parameters, run QTRK and mQTRK for MRI data deblurring, and generate plots
Supporting Functions:
- deblurring_plots.m generates an error plot for QTRK and mQTRK and grid of the image reconstructions
- circular deblurring folder contains smaller functions to functions for processing and blurring video data and defining a tensor linear systems

## tproduct Toolbox 2.0
- tproduct toolbox 2.0 (transform) folder contains code by C. Lu. Tensor-Tensor Product Toolbox. Carnegie Mellon University, June 2018. Available: https://github.com/canyilu/tproduct.
