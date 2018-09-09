%%Time: 2017.9.17
%%Name:Michael Beechan(陈兵)
%%School:Chongqing university of technology
clear,clc;
% [filename,pathname] = uigetfile('*.avi','choose the video name:');%选择视频
video = mmReader('input.avi');
height = video.Height;
width = video.Width;
tom = zeros(height,width);
%参数
NumFrames = video.NumberOfFrames;
cardinality = 2;%基数
r = 20;%给定半径
n = 20;

%
%初始化 %%%取前20帧作为模型初始化
sample = zeros(height,width,n);

for  nn = 1 : 19
    imrgb = read(video,nn);
    imgray = rgb2gray(imrgb);
    video_dis = imgray;
    if(rem(nn,2)==0)
    sample(:,:,nn/2) = imgray;  
    end
end
bg = padarray(sample,[1 1],'replicate');

%随机跟新
 %sd = zeros(height,width);
 %r = zeros(height,width);
for f = 20 : NumFrames
    imageRGB = read(video,f);
    imageRGB1 = read(video,f-1);
    imageRGB2 = read(video,f-2);
    imageRGB3 = read(video,f-3);
    imageRGB4 = read(video,f-4);
    imageRGB5 = read(video,f-5);
    imageRGB6 = read(video,f-6);
    imageRGB7 = read(video,f-7);
    imageRGB8 = read(video,f-8);
    
    image = rgb2gray(imageRGB);
    image1 = rgb2gray(imageRGB1);
    image2 = rgb2gray(imageRGB2);
    image3 = rgb2gray(imageRGB3);
    image4 = rgb2gray(imageRGB4);
    image5 = rgb2gray(imageRGB5);
    image6 = rgb2gray(imageRGB6);
    image7 = rgb2gray(imageRGB7);
    image8 = rgb2gray(imageRGB8);
    for i = 1:height
        for j = 1:width
            div = abs(sample(i,j,:) - double(image(i,j)));
            ma = find(div == (max(max(max(div)))));
            logic = div < r;
            bignum =  sum(logic);
            
            if bignum > cardinality    %确认该点为背景
                video_dis(i,j) = 0;   %该点显示灰度为0
                 tom(i,j) = 0;
                %   随机选择初始化背景中的一个点用新点进行替换
                 randz = randi(16);
                 if(randz == 10)     %确定为背景点后有1/16的概率更新背景样本和领域样本
                rands = randi(20);
                sample(i,j,ma) = image(i,j);     %要更新背景样本时从20个样本中选取差值最大的那个更新
%                 随机改变(i,j)某个背景邻域像素点的某个样本值
                 randy = round(rand)*2-1;%产生0-1之间的数，四舍五入为0或1，然后乘以2，减去1，得到的不是-1就是1
                 randx = round(rand)*2-1;
                 sample(i+1+randy,j+1+randx,rands) = image(i,j);
                end    
            else 
                     video_dis(i,j) = 255;
                     tom(i,j) = tom(i,j)+1;
                     if(tom(i,j) > 5)           %当前像素被判定为前景点超过一定次数后，用当前像素点替换到样本集中的某个样本
                       a1=abs(double(image(i,j)) - double(image1(i,j)));
                       a2=abs(double(image(i,j)) - double(image2(i,j)));
                       a3=abs(double(image(i,j)) - double(image3(i,j)));
                       a4=abs(double(image(i,j)) - double(image4(i,j)));
                       a5=abs(double(image(i,j)) - double(image5(i,j)));
                       a6=abs(double(image(i,j)) - double(image6(i,j)));
                       a7=abs(double(image(i,j)) - double(image7(i,j)));
                       a8=abs(double(image(i,j)) - double(image8(i,j)));
                       s=0;
                       if(a1 < 5)
                           s=s+1;
                       else %s=s;
                       end
                       if(a2 < 5)
                           s=s+1;
                        else %s=s;
                       end
                       if(a3 < 5)
                           s=s+1;
                       else %s=s;
                       end
                       if(a4 < 5)
                           s=s+1;
                        else %s=s;   
                       end
                       if(a5 < 5)
                           s=s+1;
                       else %s=s;
                       end
                        if(a6 < 5)
                           s=s+1;
                       else %s=s;
                        end
                        if(a7 < 5)
                           s=s+1;
                       else %s=s;
                        end
                        if(a8 < 5)
                           s=s+1;
                       else %s=s;
                       end
                       if(s>6)  %当前帧某像素点和前3帧该位置的值相差不大，说明该点是背景
                        randk = randi(20);
                        sample(i,j,randk) = image(i,j);  
                        tom(i,j)=0;
                        video_dis(i,j) = 0;
                       else
                           video_dis(i,j) = 255;
                       end
                       else
                           video_dis(i,j) = 255; 
                           tom(i,j) = tom(i,j)+1;
                     end
            end
        end
        
    end
 

      randbg = randi(n);
      out = bg(2:height+1,2:width+1,randbg);
  video_dis= imfill(video_dis,'holes');%将原图填充孔洞
        
    video_dis=imreconstruct(imerode(video_dis,strel('ball',5,1)),video_dis);   
     frameNum = f - 19;     %这里的0表示截取的开始帧数
     path='D:\数学建模代码\2017\D\附件2-典型视频\不带晃动-静态背景\office\result\';
     imwrite(video_dis,strcat(path,int2str(frameNum),'.jpg'));
  


     figure(1),subplot(1,2,1),imshow(image,[]);title(sprintf('第%d帧视频', f), 'FontWeight', 'Bold', 'Color', 'r');
    subplot(1,2,2),imshow(out,[]);title(sprintf('第%d帧背景', f), 'FontWeight', 'Bold', 'Color', 'r');
     subplot(1,2,2),imshow(video_dis,[]);title(sprintf('第%d帧目标', f), 'FontWeight', 'Bold', 'Color', 'r');
     %%drawnow;
end










