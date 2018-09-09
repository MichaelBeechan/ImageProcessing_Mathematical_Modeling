%%Time: 2017.9.18
%%Name:Michael Beechan(陈兵)
%%School:Chongqing university of technology

function []=myGPA(fileName)



mov=aviread(fileName); 
movInfo = aviinfo(fileName);
numframe = length(mov);

% nFrames = [];
% nFrames = min([movInfo.NumFrames nFrames]);

row=movInfo.Height;
col=movInfo.Width;


H1 = figure; set(H1,'name','Original Movie')%把figure的name属性改为Original Movie
scrz = get(0,'ScreenSize');
set(H1,'position',...    % [left bottom width height]
  [60  scrz(4)-100-(movInfo.Height+50)...
       movInfo.Width+50 movInfo.Height+50]);
movie(H1,mov,1,movInfo.FramesPerSecond,[25 25 0 0])
close(H1)


%movie(mov);
g=[]; 
for t=1:numframe
% % % %    mov(t).cdata=rgb2gray(mov(t).cdata); %转成灰度
   g=cat(3,g,mov(t).cdata); %合并成三维矩阵  即取出结构体中数据，共numframe页 具体做法：沿着第三维扩展A和B  这里A是迭代
end 



% % % % % % % % % % % %参考帧处理% % % % % % % % % % % % % % % % % 
gr=[]; 
gr=cat(3,gr,g(:,:,1));    %参考帧初始化
% imshow(gr);


frow=30; 
fcol=20; 
referenceframe=g(:,:,1); 
refprojrow=zeros(row,1); %行投影  即水平方向每列的投影
refprojcol=zeros(1,col); 

%参考帧行投影
refprojrowsum=0; 
for i=1:row 
    for j=1:col
       refprojrow(i)=refprojrow(i)+double(referenceframe(i,j)); 
    end 
  refprojrowsum=refprojrowsum+refprojrow(i); 
end 
refprojrowmean=refprojrowsum/row; 
refprojrow=refprojrow-refprojrowmean;    %归一化？？？？
% refprojrow=refprojrow';
% figure;plot(refprojrow); 

%余弦滤波 
for i=1:row 
    if (i<frow)||(i>row-frow) 
    refprojrow(i)=refprojrow(i)*(1+cos(pi*(frow-1-i)/frow))/2; 
end 
end 
hold on 
% plot(refprojrow,'r'); 
% xlabel('蓝色曲线为投影曲线,红色曲线为余弦滤波后的结果'); 
% title('参考帧的行投影曲线');

%参考帧列投影 
refprojcolsum=0; 
for j=1:col 
    for i=1:row 
        refprojcol(j)=refprojcol(j)+double(referenceframe(i,j)); 
    end 
    refprojcolsum=refprojcolsum+refprojcol(j); 
end 
refprojcolmean=refprojcolsum/col; 
refprojcol=refprojcol-refprojcolmean;
%refprojcol=refprojcol';
%figure;plot(refprojcol);

%余弦滤波 
for j=1:col
        if (j<fcol)||(j>col-fcol) 
           refprojcol(j)=refprojcol(j)*(1+cos(pi*(fcol-1-j)/fcol))/2; 
        end 
end 
%hold on ; plot(refprojcol,'r'); 
%xlabel('蓝色曲线为投影曲线,红色曲线为余弦滤波后的结果'); 
%title('参考帧的列投影曲线');

% % % % % % % % % % % % % 后续帧处理% % % % % % % % % % % % % % % % % % % %



for t=2:numframe

% % % %     g=cat(3,g,mov(t).cdata);
    currentframe=g(:,:,t); 

% % % % % % % % % % % %当前帧行投影 
    curprojrow=zeros(row,1); 
    curprojrowsum=0; 
    for i=1:row
        for j=1:col
            %refprojrow(i)=refprojrow(i)+double(referenceframe(i,j)); 
             curprojrow(i)=curprojrow(i)+double(currentframe(i,j)); 
        end 
        curprojrowsum=curprojrowsum+curprojrow(i); 
    end 
    curprojrowmean=curprojrowsum/row; 
    curprojrow=curprojrow-curprojrowmean; 
    %curprojrow=curprojrow'; 
    %figure;plot(curprojrow); 

    %余弦滤波
    for i=1:row 
        if (i<frow)||(i>row-frow) 
           curprojrow(i)=curprojrow(i)*(1+cos(pi*(frow-1-i)/frow))/2; 
        end 
    end 
%     figure;plot(refprojrow);
%     hold on 
%     plot(curprojrow,'r'); %xlabel('蓝色曲线为投影曲线,红色曲线为余弦滤波后的结果');
%     title('当前帧的行投影曲线'); 
    %180单位的相关运算 
    %垂直方向最大偏移正负m=30个象素 (几种电子稳像算法的初步研究全)  j=w<=2m+1=61
    cr=zeros(1,61); 
    kuozhanliang_row=zeros(61,1);
    refprojrow=cat(1,refprojrow,kuozhanliang_row);
    curprojrow=cat(1,curprojrow,kuozhanliang_row);
    
    for j=1:61 
        for i=1:row
            cr(j)=cr(j)+(refprojrow(j+i-1)-curprojrow(30+i))^2; 
        end 
    end 
%     figure;plot(cr,'g'); xlabel('垂直方向') 
    [b,jmin]=min(cr); 
    dy=31-jmin; 

% % % % % % % % % % % % % % % % 当前帧列投影 
    curprojcol=zeros(1,col); 
    curprojcolsum=0; 
    for j=1:col 
        for i=1:row 
            %refprojcol(j)=refprojcol(j)+double(referenceframe(i,j)); 
             curprojcol(j)=curprojcol(j)+double(currentframe(i,j)); 
        end 
        curprojcolsum=curprojcolsum+curprojcol(j); 
    end 
    curprojcolmean=curprojcolsum/col; 
    curprojcol=curprojcol-curprojcolmean; 
    %curprojcol=curprojcol'; 
    %figure;plot(curprojcol);
% % % % %余弦滤波
    for j=1:col 
        if (j<fcol)||(j>col-fcol) 
           curprojcol(j)=curprojcol(j)*(1+cos(pi*(fcol-1-j)/fcol))/2; 
        end 
    end 
    %figure;plot(refprojcol);hold on; 
    %plot(curprojcol,'r'); xlabel('蓝色曲线为投影曲线,红色曲线为余弦滤波后的结果') 
    %title('当前帧的列投影曲线');
    %280单位的相关运算
    %水平方向最大偏移正负20个象素 
    cc=zeros(1,41); 
    kuozhanliang_col=zeros(1,41);
    refprojcol=cat(2,refprojcol,kuozhanliang_col);
    curprojcol=cat(2,curprojcol,kuozhanliang_col);
    
    
    
    for i=1:41 
        for j=1:col 
            cc(i)=cc(i)+(refprojcol(j+i-1)-curprojcol(20+j))^2; 
        end 
    end 
%   figure;plot(cc,'g'); xlabel('水平方向') 
    [a,imin]=min(cc); 
    dx=21-imin; 

% % % % % % % % % % % % %运动补偿 % % % % % % % % % % % % %
    if dy<0   %dy<0，图currentframe相对于referenceframe向上运动了|dy| 
       a=zeros(abs(dy),col); 
       guoduframe=[a;currentframe(1:(row-abs(dy)),:)]; 
       elseif dy>0  %dy>0，图currentframe相对于referenceframe向下运动了|dy|, 
              a=zeros(dy,col); 
              guoduframe=[currentframe(1+abs(dy):row, :) ;a]; 
    else 
       guoduframe=currentframe; 
    end 
    if dx<0       %dx<0，图currentframe相对于referenceframe向左运动了|dx| 
       c=zeros(row,abs(dx)); 
       buchangframe=[c,guoduframe(:,1:col-abs(dx))]; 
       elseif dx>0     %dx>0，图currentframe相对于referenceframe向右运动了|dx|
           c=zeros(row,dx); 
           buchangframe=[guoduframe(:,abs(dx)+1:col),c]; 
    else 
        buchangframe=guoduframe; 
    end 
    
    
%   figure;imshow(buchangframe); 
    gr=cat(3,gr,buchangframe); %%%%%%%%%%%%%%%%%%%%%%%????????you mei you cuo?fang zhe li
    
    
    
    
    % % % % % % % % % % % %参考帧处理% % % % % % % % % % % % % % % % % 



frow=30; 
fcol=20; 
referenceframe=gr(:,:,t); 
refprojrow=zeros(row,1); %行投影  即水平方向每列的投影
refprojcol=zeros(1,col); 

%参考帧行投影
refprojrowsum=0; 
for i=1:row 
    for j=1:col
       refprojrow(i)=refprojrow(i)+double(referenceframe(i,j)); 
    end 
  refprojrowsum=refprojrowsum+refprojrow(i); 
end 
refprojrowmean=refprojrowsum/row; 
refprojrow=refprojrow-refprojrowmean;    %归一化？？？？
% refprojrow=refprojrow';
% figure;plot(refprojrow); 

%余弦滤波 
for i=1:row 
    if (i<frow)||(i>row-frow) 
    refprojrow(i)=refprojrow(i)*(1+cos(pi*(frow-1-i)/frow))/2; 
end 
end 
hold on 
% plot(refprojrow,'r'); 
% xlabel('蓝色曲线为投影曲线,红色曲线为余弦滤波后的结果'); 
% title('参考帧的行投影曲线');

%参考帧列投影 
refprojcolsum=0; 
for j=1:col 
    for i=1:row 
        refprojcol(j)=refprojcol(j)+double(referenceframe(i,j)); 
    end 
    refprojcolsum=refprojcolsum+refprojcol(j); 
end 
refprojcolmean=refprojcolsum/col; 
refprojcol=refprojcol-refprojcolmean;
%refprojcol=refprojcol';
%figure;plot(refprojcol);

%余弦滤波 
for j=1:col
        if (j<fcol)||(j>col-fcol) 
           refprojcol(j)=refprojcol(j)*(1+cos(pi*(fcol-1-j)/fcol))/2; 
        end 
end 
%hold on ; plot(refprojcol,'r'); 
%xlabel('蓝色曲线为投影曲线,红色曲线为余弦滤波后的结果'); 
%title('参考帧的列投影曲线');
    
    
    
   
    
%   referenceframe=buchangframe; 
%   refprojrow=curprojrow; 
%   refprojcol=curprojcol; 
end 


H2 = figure; set(H2,'name','generating final movie ...')
for i = 1:length([gr(1,1,:)])
    imshow(gr(:,:,i),[0 255]);
    %pause(0.1);
    hold on;%我加入的
    plot(102,128, 'ro' )
	movStab(i) = getframe(H2);
end
close(H2)
        
H3 = figure; set(H3,'name','Final Stabilized Movie')
imshow(gr(:,:,1),[0 255]);
curPos = get(H3,'position');                           %何意？
set(H3,'position',...    % [left bottom width height]
    [60 scrz(4)-100-(movInfo.Height+50) curPos(3:4)]);
movie(H3,movStab,1,movInfo.FramesPerSecond)

% save out final movie & workspace
movie2avi(movStab,[fileName(1:end-4) '_out.avi'], ...
    'fps',movInfo.FramesPerSecond,'compression','None');
save(sprintf('Wkspace_at_d%d-%02d-%02d_t%02d-%02d-%02d',fix(clock)))

%profile report runtime
return


