BROCCOLI
========

BROCCOLI: An open source multi-platform software for parallel analysis of fMRI data on many-core CPUs and GPUs.

BROCCOLI is a software for analysis of fMRI (functional magnetic resonance imaging) data and is written in OpenCL (Open Computing Language). The analysis can thereby be performed in parallel on many types of hardware, such as CPUs, Nvidia GPUs and AMD GPUs. The result is a significantly faster analysis than possible with existing software packages for fMRI analysis (SPM, FSL, AFNI). For example, non-linear normalization of an anatomical T1 volume to MNI space (1mm resolution) takes only 6-8 seconds with a GPU, compared to 18 minutes with FSL.

--------------------------------------------------------------------

OpenCL drivers need to be installed to be able to run BROCCOLI

Intel: http://software.intel.com/en-us/vcsource/tools/opencl-sdk

AMD: http://developer.amd.com/tools-and-sdks/heterogeneous-computing/amd-accelerated-parallel-processing-app-sdk/downloads/

Nvidia: http://www.nvidia.com/download/index.aspx

--------------------------------------------------------------------

This software is based on the following publications

Eklund, A., Andersson, M., Knutsson, H., fMRI Analysis on the GPU - Possibilities and Challenges, Computer Methods and Programs in Biomedicine, 105, 145-161, 2012

Eklund, A., Andersson, M., Knutsson, H, Fast Random Permutation Tests Enable Objective Evaluation of Methods for Single Subject fMRI Analysis, International Journal of Biomedical Imaging, Article ID 627947, 2011

Eklund, A., Andersson, M., Knutsson, H., Phase Based Volume Registration Using CUDA, International Conference on Acoustics, Speech & Signal Processing (ICASSP), p. 658-661, 2010

The code has previously been used in this publication

Eklund, A., Andersson, M., Josephson, C., Johannesson, M., Knutsson, H., Does Parametric fMRI Analysis with SPM Yield Valid Results? - An Empirical Study of 1484 Rest Datasets, NeuroImage, 61, 565-578, 2012

This paper presents an overview of GPUs in Medical Imaging

Eklund, A., Dufort, P., Forsberg, D., and LaConte, S. (2013a), Medical image processing on the GPU - Past, present and future, Medical Image Analysis, 17, 1073�1094, 2013

--------------------------------------------------------------------


