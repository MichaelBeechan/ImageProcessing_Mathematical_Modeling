%�����е�֡ͼƬת��Ϊ��Ƶ
DIR='D:\��ѧ��ģ����\����2\��̬����\';        %ͼƬ�����ļ���
file=dir(strcat(DIR,'*.jpg'));                %��ȡ����jpg�ļ�
filenum=size(file,289);                         %ͼƬ����

obj_gray = VideoWriter('aaa.avi');   %��ת���ɵ���Ƶ����
writerFrames = filenum;                       %��Ƶ֡��

%������ͼƬ����avi�ļ�
open(obj_gray);
for k = 1: writerFrames
    fname = strcat(DIR, num2str(k), '.jpg');
    frame = imread(fname);
    writeVideo(obj_gray, frame);
end
close(obj_gray);