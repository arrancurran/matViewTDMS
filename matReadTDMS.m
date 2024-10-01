% Read a TDMS file created by Tweezertron

% Add the tdms-reader library to your MATLAB path
addpath( genpath( '/Users/arrancurran/Documents/radboud/software/analysis/matViewTDMS/tdms-reader-matlab/' ) );

% Experiment name, which should be the name of the dir, the tdms and xml file
exp_name        = 'Trapped Rasp 2024-09-27' ;
% Base path of the TDMS and XML file
base_path       = '/Users/arrancurran/Documents/radboud/software/analysis/matViewTDMS/Trapped Rasp 2024-09-27/' ;
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
    acquisition_data( i , : ) = group_data.( ch_names( i ) ).data ;
end

% Loop over all stacks
for p = 1 : stacks
    % Get all acquisitions in current stack
    body = zeros( pxs_X, pxs_Y, acq_per_stack ) ;
    eye = zeros( pxs_X, pxs_Y, acq_per_stack ) ;
    for i = 1 : acq_per_stack
        acp_index   = ( p - 1 ) * acq_per_stack + ( i - 1 ) ;
        frame       = ch_names( 3 ) + num2str( acp_index ) ;
        % Get image data
        acp_data = group_data.( frame ).data ;
        body( :, :, i ) = reshape( acp_data( 1 : image_size ), pxs_X, pxs_Y ) ;
        eye( :, :, i )  = reshape( acp_data( image_size + 1 : 2 * image_size ), pxs_X, pxs_Y ) ;
        % Place code here to process individual images
        % body( :, :, i ) = uint8( body( :, :, i ) ) for example
    end
    disp( strcat( 'Stack ', num2str( p ), ' processed' ) ) ;
    % Place code here to process the current stack
    % Note that the stack data is reset at each iteration,
    % otherwise the entire experiment is stored in memory,
    % which is often larger than the local RAM
end