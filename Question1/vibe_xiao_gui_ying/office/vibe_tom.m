%%Time: 2017.9.17
%%Name:Michael Beechan(�±�)
%%School:Chongqing university of technology
clear,clc;
% [filename,pathname] = uigetfile('*.avi','choose the video name:');%ѡ����Ƶ
video = mmReader('input.avi');
height = video.Height;
width = video.Width;
tom = zeros(height,width);
%����
NumFrames = video.NumberOfFrames;
cardinality = 2;%����
r = 20;%�����뾶
n = 20;

%
%��ʼ�� %%%ȡǰ20֡��Ϊģ�ͳ�ʼ��
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

%�������
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
            
            if bignum > cardinality    %ȷ�ϸõ�Ϊ����
                video_dis(i,j) = 0;   %�õ���ʾ�Ҷ�Ϊ0
                 tom(i,j) = 0;
                %   ���ѡ���ʼ�������е�һ�������µ�����滻
                 randz = randi(16);
                 if(randz == 10)     %ȷ��Ϊ���������1/16�ĸ��ʸ��±�����������������
                rands = randi(20);
                sample(i,j,ma) = image(i,j);     %Ҫ���±�������ʱ��20��������ѡȡ��ֵ�����Ǹ�����
%                 ����ı�(i,j)ĳ�������������ص��ĳ������ֵ
                 randy = round(rand)*2-1;%����0-1֮���������������Ϊ0��1��Ȼ�����2����ȥ1���õ��Ĳ���-1����1
                 randx = round(rand)*2-1;
                 sample(i+1+randy,j+1+randx,rands) = image(i,j);
                end    
            else 
                     video_dis(i,j) = 255;
                     tom(i,j) = tom(i,j)+1;
                     if(tom(i,j) > 5)           %��ǰ���ر��ж�Ϊǰ���㳬��һ���������õ�ǰ���ص��滻���������е�ĳ������
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
                       if(s>6)  %��ǰ֡ĳ���ص��ǰ3֡��λ�õ�ֵ����˵���õ��Ǳ���
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
  video_dis= imfill(video_dis,'holes');%��ԭͼ���׶�
        
    video_dis=imreconstruct(imerode(video_dis,strel('ball',5,1)),video_dis);   
     frameNum = f - 19;     %�����0��ʾ��ȡ�Ŀ�ʼ֡��
     path='D:\��ѧ��ģ����\2017\D\����2-������Ƶ\�����ζ�-��̬����\office\result\';
     imwrite(video_dis,strcat(path,int2str(frameNum),'.jpg'));
  


     figure(1),subplot(1,2,1),imshow(image,[]);title(sprintf('��%d֡��Ƶ', f), 'FontWeight', 'Bold', 'Color', 'r');
    subplot(1,2,2),imshow(out,[]);title(sprintf('��%d֡����', f), 'FontWeight', 'Bold', 'Color', 'r');
     subplot(1,2,2),imshow(video_dis,[]);title(sprintf('��%d֡Ŀ��', f), 'FontWeight', 'Bold', 'Color', 'r');
     %%drawnow;
end










