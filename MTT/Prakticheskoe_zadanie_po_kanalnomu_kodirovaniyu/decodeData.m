function [decoded_data, b_error] = decodeData(encoded_data, H, error_list, ...
syndrome_list)
    [n, k] = size(H);
    possible_syndrome = mod(encoded_data * H', 2);
    idx = possible_syndrome(1);
    for i = 2:n
        idx = idx * 2;
        idx = idx + possible_syndrome(i);
    end
    idx = idx + 1;
    
    if (idx == 1)
        b_error = 0;
        decoded_data = encoded_data;
    else
        b_error = 1;
        decoded_data = mod(encoded_data - error_list(idx, :), 2);
    end
    
    decoded_data = decoded_data(1:k-n);
end

