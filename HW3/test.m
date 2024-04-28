% Load the video file
v = VideoReader('walk_qcif.avi');

% Define the search window size
search_window_size = [32, 32];

% Define the macroblock size (assuming standard size)
macroblock_size = [16, 16];

% Define the frames to process
frames_to_process = 11:15;

% Initialize a cell array to hold the motion vectors
motion_vectors = cell(1, length(frames_to_process));

% Initialize a cell array to hold the difference frames
difference_frames = cell(1, length(frames_to_process));

% Initialize a cell array to hold the reconstructed frames
reconstructed_frames = cell(1, length(frames_to_process));

% Read the I frame
I_frame = read(v, frames_to_process(1));

% Process each P frame
for i = 2:length(frames_to_process)
    % Read the P frame
    P_frame = read(v, frames_to_process(i));
    
    % Perform full search motion estimation
    [motion_vectors{i}, difference_frames{i}] = full_search_motion_estimation(I_frame, P_frame, macroblock_size, search_window_size);
    
    % Perform decoding to generate the reconstructed frame
    reconstructed_frames{i} = decode(I_frame, motion_vectors{i}, difference_frames{i});
    
    % Display the motion vectors using the quiver function
    figure;
    quiver(motion_vectors{i}(:,:,1), motion_vectors{i}(:,:,2));
    title(['Motion vectors for frame ', num2str(frames_to_process(i))]);
end