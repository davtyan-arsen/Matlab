function [encoded_data] = encodeData(input_data, G)
    encoded_data = mod(input_data * G, 2);
end

