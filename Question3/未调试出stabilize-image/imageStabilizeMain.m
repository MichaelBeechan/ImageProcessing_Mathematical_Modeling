function  []  =  imageStabilizeMain(fileName)
% 功能：数字图像增稳的程序
% 输入：需要增稳的AVI格式的视频（注：该视频每帧图像的像素为256×256）
if  ~exist('fileName','var')%如果不存在filename变量
fileName  =  'input1.avi';%则定义
end
nFrames = []; %用于存放待处理的视频图像帧，一个数组
 
% 读入待处理的视频图像
mov =  aviread(fileName);
movInfo  =  aviinfo(fileName);
nFrames  =  min([movInfo.NumFrames nFrames]);
 
% 建立显示图像区域
H1 = figure; set(H1,'name','Original Movie')
scrz  =  get(0,'ScreenSize');
set(H1,'position',...     
     [60 scrz(4)-100-(movInfo.Height+50) ...
         movInfo.Width+50 movInfo.Height+50]);
     
% 播放原始图像
F=getframe;
movie(H1,mov,1,movInfo.FramesPerSecond,[2 2  0  0])
close(H1)
 
% 转换每帧图像的数据类型，存放在三维数组M中
M  =  uint8(zeros(movInfo.Height,movInfo.Width,nFrames));
 for i = 1:nFrames
   M(:,:,i) = uint8(rgb2gray(mov(i).cdata));
 end

%调用图像稳定子函数stabilizeMovie_GCBPM进行每帧图像的增稳处理，并计时
tic
[Ms,Va,Vg,V]  =  stabilizeMovie_GCBPM(M);
t = toc; fprintf('%.2f seconds per frame\n',t/(nFrames-1));
 
% 存储并回放最终的处理效果
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
% 将最终结果以AVI的格式存放到工作空间(workspace)中
movie2avi(movStab,[fileName(1:end-4)  '_out.avi'],  ...
     'fps',movInfo.FramesPerSecond,'compression','None');
save(sprintf('Wkspace_at_d%d-%02d-%02d_t%02d-%02d-%02d',fix(clock)))
return
