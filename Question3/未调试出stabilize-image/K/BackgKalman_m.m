clear;
B1=1;                            %��ʼ������������������������

Q1=imread('D:\��ѧ��ģ����\����3\��֡\1.jpg');           %�����ļ���Ϣ 
Q1=double(Q1);
name1='D:\��ѧ��ģ����\����3\��֡\';
name2='.jpg';

showTime=1:4:40;      % ÿ��94֡����ʾһ�α���
j=1;                        %��������������ͼƬ��ʾ��λ��

for count1=1:length(showTime)-1
    for count=showTime(count1):showTime(count1+1)

        name=strcat(name1 ,num2str(count) ,name2);
        
        I=imread(name);                    %����ͼƬ
        I=double(I);
        B2=0.99*B1+1;                      %��ȡ0.9-0.99֮��
        K2=1/B2;                           %������������
        %I=imnoise(I,'gaussian',0);
        bg=Q1+K2*(I-Q1);                   %���±���

        B1=B2;
        Q1=bg;                             %�����µı�����Ϊ��ʱ����
       
    end
    K=uint8(bg);
    subplot(2,3,j),imshow(K);             %��ʾͼƬ
    j=j+1;                                %������1
end


imwrite(K,'D:\��ѧ��ģ����\����3\background.bmp');      %����ͼƬ���ѱ���������
