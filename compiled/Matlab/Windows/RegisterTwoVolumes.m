function [aligned_volume_nonlinear, varargout] = RegisterTwoVolumes(source_volume,reference_volume,broccoli_location,varargin)

%
% The function registers two volumes by using both linear and non-linear
% transformations. The function automagically resizes and rescales the
% source volume to match the reference volume.
%
% [aligned_volume_nonlinear, aligned_volume_linear, registration_parameters, ...
% interpolated_volume, reference_volume, displacement_x, displacement_y, displacement_z] = ...
% RegisterTwoVolumes(source_volume,reference_volume, ...
% number_of_iterations_for_linear_image_registration, ...
% number_of_iterations_for_nonlinear_image_registration, ...
% MM_Z_CUT,SIGMA,opencl_platform,opencl_device)
%
% Required input parameters
%
% source_volume    - the volume to be transformed (filename or Matlab variable)
% reference_volume - the reference volume (filename or Matlab variable)
% broccoli_location - Where BROCCOLI is installed, a string
%
% Optional input parameters
%
% source_volume_voxel_size, vector with 3 elements (for Matlab variables, use [] for filename)
% reference_volume_voxel_size, vector with 3 elements (for Matlab variables, use [] for filename)
% number_of_iterations_for_linear_image_registration (default 10)
% number_of_iterations_for_nonlinear_image_registration (default 10)
% MM_Z_CUT - millimeters to cut from the source volume in the z-direction (default 0)
% SIGMA - amount of smoothing applied to displacement field (default 5)
% opencl_platform - the OpenCL platform to use (default 0)
% opencl_device   - the OpenCL device to use (default 0)
%
% Required output parameters
%
% aligned_volume_nonlinear - The result after linear and non-linear registration
%
% Optional output parameters
%
% aligned_volume_linear - The result after linear registration
% registration_parameters - The estimated affine registration parameters
% interpolated_volume - The source volume after resizing and rescaling
% reference_volume - The reference volume
% displacement_x - Non-linear displacement field in x-direction
% displacement_y - Non-linear displacement field in y-direction
% displacement_z - Non-linear displacement field in z-direction


if length(varargin) > 0
    source_volume_voxel_size = varargin{1};
else
    source_volume_voxel_size = 0;
end

if length(varargin) > 1
    reference_volume_voxel_size = varargin{2};
else
    reference_volume_voxel_size = 0;
end

if length(varargin) > 2
    number_of_iterations_for_linear_registration = varargin{3};
else
    number_of_iterations_for_linear_registration = 10;
end

if length(varargin) > 3
    number_of_iterations_for_nonlinear_registration = varargin{4};
else
    number_of_iterations_for_nonlinear_registration = 10;
end

if length(varargin) > 4
    MM_Z_CUT = varargin{5};
else
    MM_Z_CUT = 0;
end

if length(varargin) > 5
    SIGMA = varargin{6};
else
    SIGMA = 5;
end

if length(varargin) > 6
    opencl_platform = varargin{7};
else
    opencl_platform = 0;
end

if length(varargin) > 7
    opencl_device = varargin{8};
else
    opencl_device = 0;
end

%---------------------------------------------------------------------------------------------------------------------
% README
% If you run this code in Windows, your graphics driver might stop working
% for large volumes / large filter sizes. This is not a bug in my code but is due to the
% fact that the Nvidia driver thinks that something is wrong if the GPU
% takes more than 2 seconds to complete a task. This link solved my problem
% https://forums.geforce.com/default/topic/503962/tdr-fix-here-for-nvidia-driver-crashing-randomly-in-firefox/
%---------------------------------------------------------------------------------------------------------------------

error = 0;
if ischar(source_volume)
    % Load volume to transform
    try
        volume_nii = load_nii(source_volume);
        source_volume = double(volume_nii.img);
        source_volume_voxel_size_x = volume_nii.hdr.dime.pixdim(2);
        source_volume_voxel_size_y = volume_nii.hdr.dime.pixdim(3);
        source_volume_voxel_size_z = volume_nii.hdr.dime.pixdim(4);
    catch
        error = 1;
        disp('Failed to load source volume!')
    end
else
    if source_volume_voxel_size == 0
        error = 1;
        disp('Voxel size of source volume is not defined!')
    else
        source_volume_voxel_size_x = source_volume_voxel_size(1);
        source_volume_voxel_size_y = source_volume_voxel_size(2);
        source_volume_voxel_size_z = source_volume_voxel_size(3);
    end
end

if ischar(reference_volume)
    % Load reference volume
    try
        reference_volume_nii = load_nii(reference_volume);
        reference_volume = double(reference_volume_nii.img);
        reference_volume_voxel_size_x = reference_volume_nii.hdr.dime.pixdim(2);
        reference_volume_voxel_size_y = reference_volume_nii.hdr.dime.pixdim(3);
        reference_volume_voxel_size_z = reference_volume_nii.hdr.dime.pixdim(4);
    catch
        error = 1;
        disp('Failed to load reference volume!')
    end
else
    if reference_volume_voxel_size == 0
        error = 1;
        disp('Voxel size of reference volume is not defined!')
    else
        reference_volume_voxel_size_x = reference_volume_voxel_size(1);
        reference_volume_voxel_size_y = reference_volume_voxel_size(2);
        reference_volume_voxel_size_z = reference_volume_voxel_size(3);
    end
end


% Load quadrature filters
try
    load([broccoli_location 'filters\filters_for_linear_registration.mat'])
    load([broccoli_location 'filters\filters_for_nonlinear_registration.mat'])
catch
    error = 1;
    disp('Failed to load quadrature filters!')
end

% Run the registration with OpenCL
if error == 0
    try
        start = clock;
        [aligned_volume_linear, aligned_volume_nonlinear, interpolated_volume, registration_parameters, displacement_x, displacement_y, displacement_z] = ...
            RegisterTwoVolumesMex(source_volume,reference_volume,source_volume_voxel_size_x,source_volume_voxel_size_y,source_volume_voxel_size_z,reference_volume_voxel_size_x,reference_volume_voxel_size_y,reference_volume_voxel_size_z, ...
            f1_parametric_registration,f2_parametric_registration,f3_parametric_registration, ...
            f1_nonparametric_registration,f2_nonparametric_registration,f3_nonparametric_registration,f4_nonparametric_registration,f5_nonparametric_registration,f6_nonparametric_registration, ...
            m1, m2, m3, m4, m5, m6, ...
            filter_directions_x, filter_directions_y, filter_directions_z, ...
            number_of_iterations_for_linear_registration,number_of_iterations_for_nonlinear_registration,MM_Z_CUT, SIGMA, opencl_platform, opencl_device, broccoli_location);
        registration_time = etime(clock,start);
        disp(sprintf('It took %f seconds to run the registration \n',registration_time'));
        
        
        temp = zeros(4,4);
        temp(1,4) = registration_parameters(1);
        temp(2,4) = registration_parameters(2);
        temp(3,4) = registration_parameters(3);
        temp(4,4) = 1;
        
        temp(1,1) = registration_parameters(4) + 1;
        temp(1,2) = registration_parameters(5);
        temp(1,3) = registration_parameters(6);
        
        temp(2,1) = registration_parameters(7);
        temp(2,2) = registration_parameters(8) + 1;
        temp(2,3) = registration_parameters(9);
        
        temp(3,1) = registration_parameters(10);
        temp(3,2) = registration_parameters(11);
        temp(3,3) = registration_parameters(12) + 1;
        
        registration_parameters = temp;
        
        if nargout > 1
            varargout{1} = aligned_volume_linear;
        end
        
        if nargout > 2
            varargout{2} = registration_parameters;
        end
        
        if nargout > 3
            varargout{3} = interpolated_volume;
        end
        
        if nargout > 4
            varargout{4} = reference_volume;
        end
        
        if nargout > 5
            varargout{5} = displacement_x;
        end
        
        if nargout > 6
            varargout{6} = displacement_y;
        end
        
        if nargout > 7
            varargout{7} = displacement_z;
        end
        
    catch
        disp('Failed to run the registration!')
    end
end




