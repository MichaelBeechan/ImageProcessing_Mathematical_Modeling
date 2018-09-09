%%Time: 2017.9.19
%%Name:Michael Beechan(陈兵)
%%School:Chongqing university of technology
%%Function: Review my Algorithm
function Review
img0 = imread('22.jpg');
[rows, cols] = size(img0);
img_num = 29;
TP = 0; %正确目标点数
FP = 0; %错误目标的点数
FN = 0; %错误背景点数
TN = 0; %正确背景点数
for num = 22 : img_num
    temp1 = im2bw(imread(strcat(num2str(num),'.jpg'),'jpg'));
    temp2 = im2bw(imread(strcat(num2str(num + 19),'.jpg'),'jpg'));
    for i = 1 : rows
        for j = 1 : cols
           if temp1(i,j) == 1 && temp2(i,j) == 1 
               TP = TP + 1;
           elseif temp1(i,j) == 1 && temp2(i,j) == 0 
               FP = FP + 1;
           elseif temp1(i,j) == 0 && temp2(i,j) == 1 
               FN = FN + 1;
           else temp1(i,j) == 0 && temp2(i,j) == 0;
               TN = TN + 1;
           end
        end
    end
end
Re = TP / (TP + FN) %Recall
Sp = TN / (TN + FP) %Specificity
FPR = FP / (FP + FN) %False Positive Rate
FNR = FN / (TP + FN) %False Negative Rate
PWC = 100 * (FN + FP) / (TP + FN + FP + TN) %Percentage of Wrong Classification
Precision = TP / (TP + FP)
F_Measure = (2 * Precision * Re) / (Precision + Re)







