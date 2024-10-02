% Read a TDMS file created by Tweezertron.
% Requires the tdms-reader library, when run in a linux/macOS enviroement.
% 
% Windows, install the library using the MATLAB Add-Ons.
% - DSP System Toolbox
% - Communications Toolbox
% 
% Linux/macOS, download the library from GitHub
% git clone https://github.com/sean-moore3/tdms-reader-matlab
% Or download the zip file from the GitHub URL

% Add the tdms-reader library to your MATLAB path
addpath( genpath( "/Users/arrancurran/Documents/radboud/software/third party/tdms-reader-matlab/" ) ) ;

% Base path of the TDMS and XML file
base_path       = '/Users/arrancurran/Documents/radboud/software/analysis/matViewTDMS/Trapped Rasp 2024-09-27/' ;
% Experiment name, which should be the name of the dir, the tdms and xml file
[~, exp_name, ~]= fileparts( base_path( 1 : end - 1 ) ) ;

xml_path        = fullfile( base_path, strcat( exp_name, '.xml' ) ) ;
tdms_file_path  = fullfile( base_path, strcat( exp_name, '.tdms' ) ) ;
group_name      = 'Data' ;
ch_names        = [ "timestamps__ns_", "PI_pos__um_", "frame_" ] ;

tot_acq         = str2num( readXML( xml_path, "total images" ) ) ;
stacks          = str2num( readXML( xml_path, "ZTSFrames" ) ) ;
pxs_X           = str2num( readXML( xml_path, "Pixels in X" ) ) ;
pxs_Y           = str2num( readXML( xml_path, "Pixels in Y" ) ) ;

image_size      = pxs_X * pxs_Y ;
acq_per_stack   = tot_acq / stacks ;

acq_data        = zeros( 2, tot_acq ) ;

% Read TDMS file structure
tdms_data = TDMS_getStruct(tdms_file_path) ;

% Read specific group, ie Data
group_data = tdms_data.(group_name) ;

for i = 1 : 2
    % Get Timestamps and Piezo data
    acq_data( i , : ) = group_data.( ch_names( i ) ).data ;
end

% Loop over all stacks
for p = 1 : stacks
    % Get all acquisitions in current stack
    body = zeros( pxs_X, pxs_Y, acq_per_stack ) ;
    eye = zeros( pxs_X, pxs_Y, acq_per_stack ) ;
    for i = 1 : acq_per_stack
        acq_index   = ( p - 1 ) * acq_per_stack + ( i - 1 ) ;
        frame       = ch_names( 3 ) + num2str( acq_index ) ;
        % Get image data
        acq_img = group_data.( frame ).data ;
        body( :, :, i ) = reshape( acq_img( 1 : image_size ), pxs_X, pxs_Y ) ;
        eye( :, :, i )  = reshape( acq_img( image_size + 1 : 2 * image_size ), pxs_X, pxs_Y ) ;
        % 
        % Place code here to process individual 2D images
        % 
    end
    disp( strcat( 'Stack ', num2str( p ), ' processed' ) ) ;
    % 
    % Place code here to process the current stack
    % 
    % For example:
    % cntrdBody( 1, p ) = cntrd3d( body ) ;
    % cntrdEye( 1, p ) = cntrd3d( eye ) ;
    % Note that the stack data is reset at each iteration,
    % otherwise the entire experiment is stored in memory,
    % which is often larger than the local RAM
end

