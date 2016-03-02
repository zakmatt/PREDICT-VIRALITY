clc
clear
close all
fileName = 'data.csv';
% First column represents id
dataSet = csvread(fileName,0,1);
numberOfRows = size(dataSet,1);
lastColumn = dataSet(:,168);
firstColumnsToAnalize(:,1) = dataSet(:,24);
firstColumnsToAnalize(:,2) = dataSet(:,72);
firstColumnsToAnalize(:,3) = dataSet(:,168);
firstColumnsMean = mean(firstColumnsToAnalize);
firstColumnsMax = max(firstColumnsToAnalize);
firstColumnsMedian = median(firstColumnsToAnalize);
firstColumnsMin = min(firstColumnsToAnalize);
firstColumnsMode = mode(firstColumnsToAnalize);
firstColumnsStd = std(firstColumnsToAnalize);
firstColumnsVar = var(firstColumnsToAnalize);
figure()
plot(lastColumn)
figure()
hist(lastColumn);
logLastColumn = log(lastColumn);
figure()
histfit(logLastColumn);
%movies containing cats stand for the minority of all the published ones?
%almost 900 clips(which is about 90% of the data) have similar number of
%views one week after publication

%% Create band
logLastColumnMu = mean(logLastColumn);
logLastColumnStd = std(logLastColumn);
lowerBand = logLastColumnMu - 3*logLastColumnStd;
upperBand = logLastColumnMu + 3*logLastColumnStd;

%% Get out-of-band rows indexes
k = 1;
for i=k:1:numberOfRows
   if(logLastColumn(i) < lowerBand || logLastColumn(i) > upperBand)
      indexes(k) = i;
      k = k + 1;
   end
end

%% Filter the data set
filteredDataSet = dataSet;
filteredDataSet(indexes, :) = [];
logLastColumn = log(filteredDataSet(:,168));

%% Correlation
for i=1:1:24
   logFilteredColumn = log(filteredDataSet(:,i));
%    rTemp = corrcoef(filteredDataSet(:,i), filteredDataSet(:,168));
   rTemp = corrcoef(logFilteredColumn, logLastColumn);
   R(i) = rTemp(1,2); %R - correlation coefficient. Correlation value increases with the time since publication. Nan in the first cell is a result of making log operations on 0.
end

%% Create validation and training data sets
numberOfFilteredRows = size(filteredDataSet,1);
evaluationDataSetSize = round(0.1*numberOfFilteredRows);
evaluationSampleNumbers = randperm(numberOfFilteredRows, evaluationDataSetSize);
trainingDataSet = filteredDataSet;
trainingDataSet(evaluationSampleNumbers, :) = [];
evaluationDataSet = filteredDataSet(evaluationSampleNumbers, :);

%% Inputs and Outputs
trainingDataSetInput = trainingDataSet(:, 1:167);
trainingDataSetOutput = trainingDataSet(:, 168);

evaluationDataSetInput = evaluationDataSet(:, 1:167);
evaluationDataSetOutput = evaluationDataSet(:, 168);

%% OLS - multiple input
betaCoefficient = (trainingDataSetInput'*trainingDataSetInput)\trainingDataSetInput'*trainingDataSetOutput;
calculatedTrainingOutput = trainingDataSetInput*betaCoefficient;
timeSerie = 1:1:size(trainingDataSetOutput,1);
figure();
plot(timeSerie, trainingDataSetOutput, 'r*', timeSerie, calculatedTrainingOutput, 'bo');
legend('training input', 'calculated output');
title('Training data set');
xlabel('data sample')
ylabel('number of views')
hold on;
grid on;
% validation
calculatedEvaluationOutput = evaluationDataSetInput*betaCoefficient;
figure();
timeSerieEvaluation = 1:1:size(evaluationDataSetOutput,1);
plot(timeSerieEvaluation, evaluationDataSetOutput, 'r*', timeSerieEvaluation, calculatedEvaluationOutput, 'bo');
legend('evaluation input', 'calculated output');
title('Evaluation data set');
xlabel('data sample')
ylabel('number of views')
hold on;
grid on;
%% Example of extended function
exampleAlphaOls = linearRegressorOls(trainingDataSet(:,24), trainingDataSet(:,168)); %example of use linear regressor
evaluationOutputExample = exampleAlphaOls*evaluationDataSet(:,24);

exampleAlphaOlsExtended = extendedLinearRegressorOls(90, trainingDataSet, 168); %example of use multiple-input linear regressor
evaluationOutputExtendedExample = evaluationDataSet(:,1:90)*exampleAlphaOlsExtended;
figure()
plot(1:size(evaluationDataSet,1),evaluationDataSet(:,168),'r+',1:size(evaluationDataSet,1),evaluationOutputExtendedExample,'bo');
%% mean Relative Square Error
T = size(evaluationDataSet,1);
meanRSE = mRSE(T, calculatedTrainingOutput, trainingDataSetOutput)
%% Plot first 24 hours
for j = 1:1:24
    alphaOls = linearRegressorOls(trainingDataSet(:,j), trainingDataSet(:,168));
    resultOfLinearRegressor = alphaOls*evaluationDataSet(:,j);
    mRSELinearRegressor(j)=mRSE(T,resultOfLinearRegressor, evaluationDataSet(:,168));

    alphaOlsExtended = extendedLinearRegressorOls(j, trainingDataSet, 168);
    resultOfLinearRegressorExtended = evaluationDataSet(:,1:j)*alphaOlsExtended;
    mRSELinearRegressorExtended(j)=mRSE(T,resultOfLinearRegressorExtended, evaluationDataSet(:,168));
end
figure()
plot(1:24,mRSELinearRegressor, 'r', 1:24, mRSELinearRegressorExtended, 'b');
hold on;
grid on;
legend('Linear regression','Multiple-input linear regression');