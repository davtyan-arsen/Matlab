function [code_distance, detected_errors, corrected_errors, ...
    weight_distribution] = findCodeDistance(G)
% Returns code distance and spectrum of a code with genarator matrix G
%   This a template

    [k,n] = size(G); 
    possible_inputs = dec2bin(0:2^k-1)-'0';
    code_vectors = encodeData(possible_inputs, G);
    weights = sum(code_vectors, 2);
    possible_weights = 0:n; 
    weight_distribution=sum(weights==possible_weights,1);
    
    non_zero_weights = find(weight_distribution);
    code_distance = non_zero_weights(2) - 1;
    detected_errors = code_distance - 1;
    corrected_errors = fix( (code_distance - 1) / 2 );

end

