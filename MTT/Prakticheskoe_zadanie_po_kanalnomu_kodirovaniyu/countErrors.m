function [n_errors] = countErrors(original_data, distorted_data)
    distorted_data = distorted_data(1:numel(original_data));
    n_errors = sum(original_data ~= distorted_data);
end

