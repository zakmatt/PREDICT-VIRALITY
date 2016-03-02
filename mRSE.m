function[result] = mRSE(T, calculatedOutputs, realOutputs)
% result = 0;
% for i=1:1:T
%    if isequal(calculatedOutputs(i),0) || isequal(realOutputs(i),0)
%     i = i + 1;
%    else
%     result = result + (calculatedOutputs(i)/realOutputs(i)-1)^2;
%    end
% end
% result = 1/T * result;
tempMRSE = calculatedOutputs./realOutputs;
tempMRSE = tempMRSE - 1;
tempMRSE = tempMRSE'*tempMRSE;
result = 1/T * tempMRSE;
end