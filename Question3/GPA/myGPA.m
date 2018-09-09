%%Time: 2017.9.18
%%Name:Michael Beechan(�±�)
%%School:Chongqing university of technology

function []=myGPA(fileName)



mov=aviread(fileName); 
movInfo = aviinfo(fileName);
numframe = length(mov);

% nFrames = [];
% nFrames = min([movInfo.NumFrames nFrames]);

row=movInfo.Height;
col=movInfo.Width;


H1 = figure; set(H1,'name','Original Movie')%��figure��name���Ը�ΪOriginal Movie
scrz = get(0,'ScreenSize');
set(H1,'position',...    % [left bottom width height]
  [60  scrz(4)-100-(movInfo.Height+50)...
       movInfo.Width+50 movInfo.Height+50]);
movie(H1,mov,1,movInfo.FramesPerSecond,[25 25 0 0])
close(H1)


%movie(mov);
g=[]; 
for t=1:numframe
% % % %    mov(t).cdata=rgb2gray(mov(t).cdata); %ת�ɻҶ�
   g=cat(3,g,mov(t).cdata); %�ϲ�����ά����  ��ȡ���ṹ�������ݣ���numframeҳ �������������ŵ���ά��չA��B  ����A�ǵ���
end 



% % % % % % % % % % % %�ο�֡����% % % % % % % % % % % % % % % % % 
gr=[]; 
gr=cat(3,gr,g(:,:,1));    %�ο�֡��ʼ��
% imshow(gr);


frow=30; 
fcol=20; 
referenceframe=g(:,:,1); 
refprojrow=zeros(row,1); %��ͶӰ  ��ˮƽ����ÿ�е�ͶӰ
refprojcol=zeros(1,col); 

%�ο�֡��ͶӰ
refprojrowsum=0; 
for i=1:row 
    for j=1:col
       refprojrow(i)=refprojrow(i)+double(referenceframe(i,j)); 
    end 
  refprojrowsum=refprojrowsum+refprojrow(i); 
end 
refprojrowmean=refprojrowsum/row; 
refprojrow=refprojrow-refprojrowmean;    %��һ����������
% refprojrow=refprojrow';
% figure;plot(refprojrow); 

%�����˲� 
for i=1:row 
    if (i<frow)||(i>row-frow) 
    refprojrow(i)=refprojrow(i)*(1+cos(pi*(frow-1-i)/frow))/2; 
end 
end 
hold on 
% plot(refprojrow,'r'); 
% xlabel('��ɫ����ΪͶӰ����,��ɫ����Ϊ�����˲���Ľ��'); 
% title('�ο�֡����ͶӰ����');

%�ο�֡��ͶӰ 
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

%�����˲� 
for j=1:col
        if (j<fcol)||(j>col-fcol) 
           refprojcol(j)=refprojcol(j)*(1+cos(pi*(fcol-1-j)/fcol))/2; 
        end 
end 
%hold on ; plot(refprojcol,'r'); 
%xlabel('��ɫ����ΪͶӰ����,��ɫ����Ϊ�����˲���Ľ��'); 
%title('�ο�֡����ͶӰ����');

% % % % % % % % % % % % % ����֡����% % % % % % % % % % % % % % % % % % % %



for t=2:numframe

% % % %     g=cat(3,g,mov(t).cdata);
    currentframe=g(:,:,t); 

% % % % % % % % % % % %��ǰ֡��ͶӰ 
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

    %�����˲�
    for i=1:row 
        if (i<frow)||(i>row-frow) 
           curprojrow(i)=curprojrow(i)*(1+cos(pi*(frow-1-i)/frow))/2; 
        end 
    end 
%     figure;plot(refprojrow);
%     hold on 
%     plot(curprojrow,'r'); %xlabel('��ɫ����ΪͶӰ����,��ɫ����Ϊ�����˲���Ľ��');
%     title('��ǰ֡����ͶӰ����'); 
    %180��λ��������� 
    %��ֱ�������ƫ������m=30������ (���ֵ��������㷨�ĳ����о�ȫ)  j=w<=2m+1=61
    cr=zeros(1,61); 
    kuozhanliang_row=zeros(61,1);
    refprojrow=cat(1,refprojrow,kuozhanliang_row);
    curprojrow=cat(1,curprojrow,kuozhanliang_row);
    
    for j=1:61 
        for i=1:row
            cr(j)=cr(j)+(refprojrow(j+i-1)-curprojrow(30+i))^2; 
        end 
    end 
%     figure;plot(cr,'g'); xlabel('��ֱ����') 
    [b,jmin]=min(cr); 
    dy=31-jmin; 

% % % % % % % % % % % % % % % % ��ǰ֡��ͶӰ 
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
% % % % %�����˲�
    for j=1:col 
        if (j<fcol)||(j>col-fcol) 
           curprojcol(j)=curprojcol(j)*(1+cos(pi*(fcol-1-j)/fcol))/2; 
        end 
    end 
    %figure;plot(refprojcol);hold on; 
    %plot(curprojcol,'r'); xlabel('��ɫ����ΪͶӰ����,��ɫ����Ϊ�����˲���Ľ��') 
    %title('��ǰ֡����ͶӰ����');
    %280��λ���������
    %ˮƽ�������ƫ������20������ 
    cc=zeros(1,41); 
    kuozhanliang_col=zeros(1,41);
    refprojcol=cat(2,refprojcol,kuozhanliang_col);
    curprojcol=cat(2,curprojcol,kuozhanliang_col);
    
    
    
    for i=1:41 
        for j=1:col 
            cc(i)=cc(i)+(refprojcol(j+i-1)-curprojcol(20+j))^2; 
        end 
    end 
%   figure;plot(cc,'g'); xlabel('ˮƽ����') 
    [a,imin]=min(cc); 
    dx=21-imin; 

% % % % % % % % % % % % %�˶����� % % % % % % % % % % % % %
    if dy<0   %dy<0��ͼcurrentframe�����referenceframe�����˶���|dy| 
       a=zeros(abs(dy),col); 
       guoduframe=[a;currentframe(1:(row-abs(dy)),:)]; 
       elseif dy>0  %dy>0��ͼcurrentframe�����referenceframe�����˶���|dy|, 
              a=zeros(dy,col); 
              guoduframe=[currentframe(1+abs(dy):row, :) ;a]; 
    else 
       guoduframe=currentframe; 
    end 
    if dx<0       %dx<0��ͼcurrentframe�����referenceframe�����˶���|dx| 
       c=zeros(row,abs(dx)); 
       buchangframe=[c,guoduframe(:,1:col-abs(dx))]; 
       elseif dx>0     %dx>0��ͼcurrentframe�����referenceframe�����˶���|dx|
           c=zeros(row,dx); 
           buchangframe=[guoduframe(:,abs(dx)+1:col),c]; 
    else 
        buchangframe=guoduframe; 
    end 
    
    
%   figure;imshow(buchangframe); 
    gr=cat(3,gr,buchangframe); %%%%%%%%%%%%%%%%%%%%%%%????????you mei you cuo?fang zhe li
    
    
    
    
    % % % % % % % % % % % %�ο�֡����% % % % % % % % % % % % % % % % % 



frow=30; 
fcol=20; 
referenceframe=gr(:,:,t); 
refprojrow=zeros(row,1); %��ͶӰ  ��ˮƽ����ÿ�е�ͶӰ
refprojcol=zeros(1,col); 

%�ο�֡��ͶӰ
refprojrowsum=0; 
for i=1:row 
    for j=1:col
       refprojrow(i)=refprojrow(i)+double(referenceframe(i,j)); 
    end 
  refprojrowsum=refprojrowsum+refprojrow(i); 
end 
refprojrowmean=refprojrowsum/row; 
refprojrow=refprojrow-refprojrowmean;    %��һ����������
% refprojrow=refprojrow';
% figure;plot(refprojrow); 

%�����˲� 
for i=1:row 
    if (i<frow)||(i>row-frow) 
    refprojrow(i)=refprojrow(i)*(1+cos(pi*(frow-1-i)/frow))/2; 
end 
end 
hold on 
% plot(refprojrow,'r'); 
% xlabel('��ɫ����ΪͶӰ����,��ɫ����Ϊ�����˲���Ľ��'); 
% title('�ο�֡����ͶӰ����');

%�ο�֡��ͶӰ 
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

%�����˲� 
for j=1:col
        if (j<fcol)||(j>col-fcol) 
           refprojcol(j)=refprojcol(j)*(1+cos(pi*(fcol-1-j)/fcol))/2; 
        end 
end 
%hold on ; plot(refprojcol,'r'); 
%xlabel('��ɫ����ΪͶӰ����,��ɫ����Ϊ�����˲���Ľ��'); 
%title('�ο�֡����ͶӰ����');
    
    
    
   
    
%   referenceframe=buchangframe; 
%   refprojrow=curprojrow; 
%   refprojcol=curprojcol; 
end 


H2 = figure; set(H2,'name','generating final movie ...')
for i = 1:length([gr(1,1,:)])
    imshow(gr(:,:,i),[0 255]);
    %pause(0.1);
    hold on;%�Ҽ����
    plot(102,128, 'ro' )
	movStab(i) = getframe(H2);
end
close(H2)
        
H3 = figure; set(H3,'name','Final Stabilized Movie')
imshow(gr(:,:,1),[0 255]);
curPos = get(H3,'position');                           %���⣿
set(H3,'position',...    % [left bottom width height]
    [60 scrz(4)-100-(movInfo.Height+50) curPos(3:4)]);
movie(H3,movStab,1,movInfo.FramesPerSecond)

% save out final movie & workspace
movie2avi(movStab,[fileName(1:end-4) '_out.avi'], ...
    'fps',movInfo.FramesPerSecond,'compression','None');
save(sprintf('Wkspace_at_d%d-%02d-%02d_t%02d-%02d-%02d',fix(clock)))

%profile report runtime
return


