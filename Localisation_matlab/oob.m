
%form labels vector

function [errorrate] = oob(data, num_loops)

if(num_loops == 9)
    labels = ["Loop 1","Loop 2", "Loop 3","Loop 4" , "Loop 5", "Loop 6","Loop 7" , "Loop 8", "Loop 9"];
elseif (num_loops == 5)
    labels = ["Loop 1" "Loop 3", "Loop 5", "Loop 7" , "Loop 9"];
else 
    labels = ["Loop 1", "Loop 5", "Loop 9"];   
end
c = 1;



%split data 60/40 samples for training/test data
train = data(:,1:60);
test = data(:,61:end);
data_train = zeros(60*num_loops,1);
data_test = zeros(40*num_loops,1);
for i = 1:num_loops
    data_train((60*(i-1)+1):60*(i)) = train(i,:);
    data_test((40*(i-1)+1):(40*(i))) = test(i,:);
end
c = 1;
for i = 1:num_loops
    for j  = 1:60
        train_label(c) = labels(i);
        c = c+1;
    end
end
c = 1;
for i = 1:num_loops
    for j  = 1:40
        test_label(c) = labels(i);
        c = c+1;
    end
end



%with lowest OOB error
NumTrees = 1;

%create bagging model using training data
model_bagging = TreeBagger(NumTrees,data_train,train_label, Method="classification", OOBPrediction="on");


% %plot out of bag classification error
% figure
% plot(oobError(model_bagging))
% xlabel("Number of Grown Trees")
% ylabel("Out-of-Bag Classification Error")
% title('Average Out-of-Bag Error for Different Numbers of Trees')
% set(get (gca, 'XAxis'), 'FontWeight', 'bold');
% set(get (gca, 'YAxis'), 'FontWeight', 'bold');
% fontsize(gcf,12,"points")

%make predictions using designed model and test data
predictions = predict(model_bagging, data_test);

errorrate = sum(string(predictions) ~= string(test_label')) / length(test_label);

%compute confusion matrix
% figure
% confusionchart(cellstr(test_label), predictions)
% title('Confusion Matrix')
