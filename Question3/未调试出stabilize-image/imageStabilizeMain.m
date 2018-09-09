function  []  =  imageStabilizeMain(fileName)
% ���ܣ�����ͼ�����ȵĳ���
% ���룺��Ҫ���ȵ�AVI��ʽ����Ƶ��ע������Ƶÿ֡ͼ�������Ϊ256��256��
if  ~exist('fileName','var')%���������filename����
fileName  =  'input1.avi';%����
end
nFrames = []; %���ڴ�Ŵ��������Ƶͼ��֡��һ������
 
% ������������Ƶͼ��
mov =  aviread(fileName);
movInfo  =  aviinfo(fileName);
nFrames  =  min([movInfo.NumFrames nFrames]);
 
% ������ʾͼ������
H1 = figure; set(H1,'name','Original Movie')
scrz  =  get(0,'ScreenSize');
set(H1,'position',...     
     [60 scrz(4)-100-(movInfo.Height+50) ...
         movInfo.Width+50 movInfo.Height+50]);
     
% ����ԭʼͼ��
F=getframe;
movie(H1,mov,1,movInfo.FramesPerSecond,[2 2  0  0])
close(H1)
 
% ת��ÿ֡ͼ����������ͣ��������ά����M��
M  =  uint8(zeros(movInfo.Height,movInfo.Width,nFrames));
 for i = 1:nFrames
   M(:,:,i) = uint8(rgb2gray(mov(i).cdata));
 end

%����ͼ���ȶ��Ӻ���stabilizeMovie_GCBPM����ÿ֡ͼ������ȴ�������ʱ
tic
[Ms,Va,Vg,V]  =  stabilizeMovie_GCBPM(M);
t = toc; fprintf('%.2f seconds per frame\n',t/(nFrames-1));
 
% �洢���ط����յĴ���Ч��
H2 = figure; set(H2,'name','generating final movie ...')
for i = 1:length([Ms(1,1,:)])
     imshow(Ms(:,:,i),[0 255]);
movStab(i) =  getframe(H2);
end
close(H2)
H3 = figure; set(H3,'name','Final Stabilized Movie')
imshow(Ms(:,:,1),[0  255]);
curPos  =  get(H3,'position');
set(H3,'position',...     
     [60 scrz(4)-100-(movInfo.Height+50) curPos(3:4)]);
movie(H3,movStab,1,movInfo.FramesPerSecond)
% �����ս����AVI�ĸ�ʽ��ŵ������ռ�(workspace)��
movie2avi(movStab,[fileName(1:end-4)  '_out.avi'],  ...
     'fps',movInfo.FramesPerSecond,'compression','None');
save(sprintf('Wkspace_at_d%d-%02d-%02d_t%02d-%02d-%02d',fix(clock)))
return
