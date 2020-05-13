function [error_list, syndrome_list] = generateSyndromes(H)
    [~,n] = size(H);
    error_list = dec2bin(0:2^n-1)-'0';
    [~, idx] = sort(sum(error_list, 2));
    error_list = error_list(idx, :);
    syndrome_list = mod(error_list * H', 2);
    
    [unique_syndromes, idx, ~] = unique(syndrome_list, 'rows');
    syndrome_list = unique_syndromes;
    error_list = error_list(idx, :);
    
    [syndrome_list, idx] = sortrows(syndrome_list);
    error_list = error_list(idx, :);
end

