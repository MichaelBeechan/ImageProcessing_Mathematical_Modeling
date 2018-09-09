clear;
B1=1;                            %初始化参数，用来计算增益因子

Q1=imread('D:\数学建模代码\问题3\单帧\1.jpg');           %读入文件信息 
Q1=double(Q1);
name1='D:\数学建模代码\问题3\单帧\';
name2='.jpg';

showTime=1:4:40;      % 每隔94帧，显示一次背景
j=1;                        %变量，用来控制图片显示的位置

for count1=1:length(showTime)-1
    for count=showTime(count1):showTime(count1+1)

        name=strcat(name1 ,num2str(count) ,name2);
        
        I=imread(name);                    %读入图片
        I=double(I);
        B2=0.99*B1+1;                      %α取0.9-0.99之间
        K2=1/B2;                           %计算增益因子
        %I=imnoise(I,'gaussian',0);
        bg=Q1+K2*(I-Q1);                   %更新背景

        B1=B2;
        Q1=bg;                             %将更新的背景作为初时背景
       
    end
    K=uint8(bg);
    subplot(2,3,j),imshow(K);             %显示图片
    j=j+1;                                %变量加1
end


imwrite(K,'D:\数学建模代码\问题3\background.bmp');      %保存图片，已被后面所用
