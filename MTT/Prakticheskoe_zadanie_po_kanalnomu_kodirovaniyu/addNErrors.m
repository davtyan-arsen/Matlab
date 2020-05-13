function [distortedData] = addNErrors(net_data,n_errors)
% Add n_errors to block net_data

    n = numel(net_data);
    assert(n_errors<=n && n_errors>=0);
    
    sv = [ones(1, n_errors), zeros(1, n-n_errors)];
    order = randperm(n);
    uv = sv(order);
    
    distortedData = mod( net_data + uv, 2);
    
end

