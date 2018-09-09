%将所有单帧图片转换为视频
DIR='D:\数学建模代码\问题2\动态背景\';        %图片所在文件夹
file=dir(strcat(DIR,'*.jpg'));                %读取所有jpg文件
filenum=size(file,289);                         %图片总数

obj_gray = VideoWriter('aaa.avi');   %所转换成的视频名称
writerFrames = filenum;                       %视频帧数

%将单张图片存在avi文件
open(obj_gray);
for k = 1: writerFrames
    fname = strcat(DIR, num2str(k), '.jpg');
    frame = imread(fname);
    writeVideo(obj_gray, frame);
end
close(obj_gray);