function [distortedData] = addPErrors(net_data,p_error)
% Add errors having probability p_error to block net_data

    error_v = rand(size(net_data)) < p_error ;
    distortedData = double( xor(net_data, error_v)) ;
    
end

