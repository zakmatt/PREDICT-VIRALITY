function [ alphaOlsExtended ] = extendedLinearRegressorOls( n, V_n, compareToColumn)
    inputArguments = V_n(:,1:n);
    outputArguments = V_n(:,compareToColumn);
    alphaOlsExtended = (inputArguments'*inputArguments)\inputArguments'*outputArguments;        
end

