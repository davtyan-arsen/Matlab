% One iteration
clear
clc
load('codes')

code = codes(2);    % 1-6 , not 3
fprintf("%s\n", code.name);

k = size(code.G,1); % input block size
m = size(code.H,1); % check block size
n = size(code.G,2); % output block size

error_number = 1;

data = randi([0 1], 1, k);

% 1: Encode data
encoded_data = encodeData(data, code.G);

% 2: Find spectrum and code distance
[code_distance, detected_errors, corrected_errors, ...
    weight_distribution] = findCodeDistance(code.G); 

possible_weights = 0:n; 
fprintf("Weight spectrum\n");
disp([possible_weights;weight_distribution])

fprintf("Code distance: %d\n", code_distance);   
fprintf("Detected error weight: %d\n", detected_errors);   
fprintf("Corrected error weight: %d\n", corrected_errors); 

% Imagine there is a noisy channel here %
distorted_data = addNErrors(encoded_data, error_number);

% 3: Count errors
fprintf("The distorted message of %d bits contains %d errors\n", ...
    numel(encoded_data), ...
    countErrors(data, distorted_data));

% 4: Generate errors and syndromes
[error_list,syndrome_list] = generateSyndromes(code.H);

% 5: Decode data
[decoded_data, b_error] = decodeData(distorted_data, code.H, error_list, syndrome_list);

if b_error
    fprintf("Errors have been detected\n");
else
    fprintf("No errors have been detected\n");
end
fprintf("The decoded message of %d bits contains %d errors\n", ...
    numel(encoded_data), ...
    countErrors(data, decoded_data));
