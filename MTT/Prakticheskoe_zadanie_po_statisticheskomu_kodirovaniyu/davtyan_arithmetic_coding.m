clc;

load('data/3.mat');     % writes to variable 'data'

[alphabet, probabilities] = getAlphabetAndProbabilities(data); 

fprintf("Zero order symbol entropy: %g bits\n", log2(numel(alphabet)));
fprintf("Symbol entropy: %g bits\n", - sum(probabilities .* log2(probabilities)));

fprintf("Input stream bit volume: %d bit\n", 8 * numel(data));

[ encoded_data, encoded_parameters ] = encodeData( data );

fprintf("Coded data length: %d bits\n", numel(encoded_data));
fprintf("Coded metadata length: %d bits\n", numel(encoded_parameters));
fprintf("Total code length: %d bits\n", numel(encoded_data) + numel(encoded_parameters));

fprintf("Average code length per symbol: %g bits\n", numel(encoded_data) / numel(data));
fprintf("Average total length per symbol: %g bits\n", (numel(encoded_data) + numel(encoded_parameters)) / numel(data));

decoded_data = decodeData( encoded_data, encoded_parameters );

if (numel(data)~=numel(decoded_data))
    fprintf("Length mismatch\n");
elseif (any(data~=decoded_data))
    fprintf("Wrong symbol\n");
else
    fprintf("Correct decoding!\n");
end

function [alphabet, probs] = getAlphabetAndProbabilities(X)
    alphabet = unique(X);
    numOccur = @(c) (numel(X(X == c)));
    probs = arrayfun(numOccur, alphabet) / numel(X);
end

% gets the table of cumulative totals
function cumTotals = getCumTotals(freqs)
    cumTotals = zeros(1, numel(freqs) + 1);
    % eot symbol has a total of 1 and it's first in the table
    cumTotals(2) = 1;
    for i = 3:numel(cumTotals)
        cumTotals(i) = cumTotals(i-1) + freqs(i-2);
    end
    cumTotals(end + 1) = sum(freqs);
end

function res = OutputBit(num16)
    if (num16 == 0x0000)
        res = 0;
    else
        res = 1;
    end
end

function [ encoded_data, encoded_parameters ] = encodeData( data )
    % getting the alphabet and probabilities and sorting them in ascending order
    [alphabet, probs] = getAlphabetAndProbabilities(data);
    [probs, sortIndex] = sort(probs);
    alphabet = alphabet(sortIndex);
    
    % encoding the alphabet
    symbolsCount = dec2bin(numel(alphabet), 8);
    encodedSymbols = reshape(dec2bin(alphabet, 8)', 1, []);
    
    % converting probabilities to corresponding numbers from 1 to 255
    freqs = round(probs * 255);
    freqs(freqs == 0) = 1; % making sure each symbol has a frequency of at least 1
    encodedFreqs = reshape(dec2bin(freqs, 8)', 1, []);
    
    encoded_parameters = append(symbolsCount, encodedSymbols, encodedFreqs);
    encoded_data = [];
   
    eotSymbol = '~';
    symbols = [eotSymbol, alphabet];
    cumTotals = getCumTotals(freqs); % getting the cumulative totals
    
    % encoding process
    
    low = 0x0000;
    high = 0xffff;
    underflowBits = 0;
    
    data(end + 1) = eotSymbol;
    dataLen = numel(data);
    for s = 1:dataLen
        index = find(symbols == data(s));
        
        range = double(high - low) + 1;
        
        high = low + uint16(range * cumTotals(index + 1) / cumTotals(end) - 1);
        low = low + uint16(range * cumTotals(index) / cumTotals(end));
        
        while (true)
           if (bitand(high, 0x8000) == bitand(low, 0x8000))
               encoded_data(end + 1) = OutputBit(bitand(high, 0x8000));
               
               while (underflowBits > 0)
                  encoded_data(end + 1) = OutputBit(bitand(bitcmp(high), 0x8000));
                  underflowBits = underflowBits - 1;
               end
               
           elseif (bitand(low, 0x4000) && ~bitand(high, 0x4000))
               underflowBits = underflowBits + 1;
               low = bitand(low, 0x3fff);
               high = bitor(high, 0x4000);
           else
               break;
           end
           low = bitshift(low, 1);
           high = bitshift(high, 1);
           high = bitor(high, 0x0001);
        end
    end
    
    encoded_data(end + 1) = OutputBit(bitand(low, 0x4000));
    underflowBits = underflowBits + 1;
    while (underflowBits >= 0)
        encoded_data(end + 1) = OutputBit(bitand(bitcmp(low), 0x4000));
        underflowBits = underflowBits - 1;
    end
    
    % adding extra 2 bytes of zeros for correct decoding
    encoded_data = [encoded_data, zeros(1, 16)];
end

% getSymbol finds the symbol and its position corresponding to the given index
function [symbol, symbolIdx] = getSymbol(count, cumTotals, symbols)
    for i = 1:numel(cumTotals)-1
        if (count >= cumTotals(i) && count < cumTotals(i + 1))
           symbol = symbols(i);
           symbolIdx = i;
           break;
        end
    end
end

function decoded_data = decodeData( encoded_data, encoded_parameters )
    % converting the parameters from binary to decimal
    encoded_parameters = bin2dec(reshape(encoded_parameters, 8, [])');
    symbolsCount = encoded_parameters(1);
    symbols = char(encoded_parameters(2:1 + symbolsCount));
    freqs = encoded_parameters(2 + symbolsCount:end);
    
    decoded_data = '';
    
    eotSymbol = '~';
    symbols = [eotSymbol, symbols'];
    cumTotals = getCumTotals(freqs);
    
    % initializing the decoder
    inputBit = 1;
    code = 0x0000;
    for i = 1:16
       code = bitshift(code, 1);
       code = code + encoded_data(inputBit);
       inputBit = inputBit + 1;
    end
    
    % decoding process

    low = 0x0000;
    high = 0xffff;
  
    % roundFunc = @(x) uint16(floor(x))
    
    while (inputBit <= numel(encoded_data))
        range = double(high - low) + 1;
        index = fix( (double(code - low) * cumTotals(end)) / range );
        
        [symbol, symbolIdx] = getSymbol(index, cumTotals, symbols);
        if (symbol == eotSymbol)
            break; 
        end
        decoded_data(end + 1) = symbol;
        
        high = low + uint16(range * cumTotals(symbolIdx + 1) / cumTotals(end) - 1);
        low = low + uint16(range * cumTotals(symbolIdx) / cumTotals(end));
        
        while (true)
            if (bitand(high, 0x8000) == bitand(low, 0x8000))
            
            elseif ((bitand(low, 0x4000) == 0x4000) && (bitand(high, 0x4000) == 0x000))
                code = bitxor(code, 0x4000);
                low = bitand(low, 0x3fff);
                high = bitor(high, 0x4000);
            else
                break;
            end
            
            low = bitshift(low, 1);
            high = bitshift(high, 1);
            high = bitor(high, 0x0001);
            code = bitshift(code, 1);
            code = code + encoded_data(inputBit);
            inputBit = inputBit + 1;
        end
    end
end