%����Ƶת��Ϊ����ͼƬ
clear
clc

file_name = 'input.avi';        %��Ƶ�����ļ���
obj = VideoReader(file_name);     %��ȡ��Ƶ�ļ�

numFrames = obj.NumberOfFrames;   %��Ƶ�ܵ�֡�� 
for k = 1: numFrames
    frame = read(obj,k);
    %imshow(frame);                
    gray_frame = rgb2gray(frame); %��ÿһ֡Ϊ��ɫͼƬ��ת��Ϊ�Ҷ�ͼ
    imshow(frame);                %��ʾÿһ֡ͼƬ
    %����ÿһ֡ͼƬ
    imwrite(gray_frame,strcat('D:\��ѧ��ģ����\����3\��֡\',num2str(k),'.jpg'),'jpg');
end
