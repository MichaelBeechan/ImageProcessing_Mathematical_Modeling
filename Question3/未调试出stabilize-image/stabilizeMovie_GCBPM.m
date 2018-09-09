function  [Ms,Va,Vg,V]  =  stabilizeMovie_GCBPM(M)
% ��ɫ�����㷨
% ���룺M-������Ƶ
% �����Ms-�ȶ�ͼ������
%       Va-�����˶�ʸ��
%       Vg-ȫ���˶�ʸ��
%       V-�˶�ʸ��
% �ο����ף�
%      S. Ko, S. Lee, S. Jeon, and E. Kang. Fast digital image stabilizer
%      based on gray-coded bit-plane matching. IEEE Transactions on
%      Consumer Electronics, vol. 45, no. 3, pp. 598-603, Aug. 1999.
% ��ʼ��ȫ�ֱ���
debug_disp = 0;                  

% ��ʼ���㷨�ı���
bit = 5;                         % ��ѻҶȱ���λ
N = 112;                         % ƥ���ߴ�(��ΪNxN��������)
D1 = 0.95;                       % ����ϵ��(0 < D1 < 1)
logSearchEnable = 1;           % 1 ����logrigtmic 3-2-1 ƥ������
                                 
nSteps = 3;                      % log search�Ĳ�����3������
rotEnable = 0;                   % 0 ������ԭʼ��ת��GCBPM

[h,w,nFr] = size(M);             % ÿһ֡ͼ��Ŀ�Ⱥͳ���
if ( ~rem(w,2) & ~rem(h,2) )
     S = uint8(zeros(h/2,w/2,2,4)); 
else
     error('video width/height must both be even # of pixels')
end
hw = waitbar(0,'Please wait...');
p = (h/2-N)/2;                   % ���������λ��
bxor = uint8(zeros(N));          % ��ֵ
Cj = 1e9*ones(2*p+1);            % ��ز���
V = zeros(4,2,nFr);              % �˶�ʸ��
Vg = zeros(nFr,2); %[0 0];       % ȫ���˶�ʸ��
Va = zeros(nFr,2);               % �����˶�ʸ��
Ms = uint8(zeros(h,w,nFr));      % ��ʼ���ȶ�ͼ������
 
% ѭ������ÿһ֡ͼ��
for fr = 1:nFr
     waitbar((fr-1)/nFr,hw) % ��ʾ����
% ��ûҶȱ���λƽ��
     [Mg] = uint8(getGrayCodeBitPlane(M,bit,fr,debug_disp));
  
     S(:,:,2,1) = Mg( 1:h/2,       1:w/2        ); % UL, S1
     S(:,:,2,2) = Mg( 1:h/2,       w/2+1:end    ); % UR, S2
     S(:,:,2,3) = Mg( h/2+1:end,  1:w/2        ); % LL, S3
     S(:,:,2,4) = Mg( h/2+1:end,  w/2+1:end    ); % LR, S4
   
     if fr > 1 % �ڵ�һ֡ͼ��֮�������㷨
       
         for j = 1:4 % ѭ������ÿһ����ͼ��
             if ~logSearchEnable
                 % ��ȷ����
                 for m_pos = 1:2*p+1 % ѭ������ÿһ�����ܵ�λ��
                     for n_pos = 1:2*p+1
                       
                         % ��������Զ���
                         bxor = bitxor( ...  
                             S(p+1:p+N,p+1:p+N,2,j) , ...
                             S(m_pos:m_pos+N-1,n_pos:n_pos+N-1,1,j) );
                         Cj(m_pos,n_pos) = sum(bxor(:)); 
                       
                     end
                 end 
         % ������С��Cjλ��
                 [tmp,m_pos_min] = min(Cj);
                 [tmp,n_pos_min] = min(tmp); clear tmp;
                 m_pos_min=m_pos_min(n_pos_min);
             else
                 % log����
                 %  ע������ͼ�������Ϊ256x256 
                 firstJmp = 4;
                 prev_m_pos = 9; prev_n_pos = 9; % �����Ŀ�ʼ
                 for iter = 1:nSteps
                     
                     Cj = 1e9*ones(2*p+1); % ������ض���
                     curJmp = firstJmp./2.^(iter-1);
                     for m_pos = prev_m_pos-curJmp:curJmp:prev_m_pos+curJmp
                         for n_pos = prev_n_pos-curJmp:curJmp:prev_n_pos+curJmp
                           
                             % ������ض���
                             bxor = bitxor( ...  % could be very fast HW
                                 S(p+1:p+N,p+1:p+N,2,j) , ...
                                S(m_pos:m_pos+N-1,n_pos:n_pos+N-1,1,j) );
                             Cj(m_pos,n_pos) = sum(bxor(:));
                           
                         end
                     end
 
                     %  ������С��Cjλ��                   
[tmp,m_pos_min] = min(Cj);
                     [tmp,n_pos_min] = min(tmp); clear tmp;
                     m_pos_min=m_pos_min(n_pos_min);
                    
                     prev_m_pos = m_pos_min;
                     prev_n_pos = n_pos_min;
                   
                 end                
             end 
             V(j,:,fr) = [m_pos_min n_pos_min]-p-1; % V[1] V[2]
         end 
         % ���㵱ǰȫ���˶�ʸ��
         Vg(fr,:) = median([V(:,:,fr);Vg_prev]);
       
         % ����������������һ֡��ȫ���˶�ʸ��
         Va(fr,:) = D1 * Va_prev + Vg(fr,:);
       
     end 
 
     % �洢��ǰ֡ͼ��Ϊ��һ֡ͼ��
     S(:,:,1,:) = S(:,:,2,:);     % �Ҷȱ�����ͼ��
     Vg_prev = Vg(fr,:);          % ȫ���˶�ʸ��
     Va_prev = Va(fr,:);          % �����˶�ʸ��
     
     switch rotEnable
     case 0
         % ƽ��У��
         %  (not sub-pixel for now)
         r = round(Va(fr,1)); % num rows moved
         c = round(Va(fr,2)); % num columns moved
         Ms(max([1 1+r]):min([h h+r]),max([1 1+c]):min([w w+c]),fr) = ...
             M(max([1 1-r]):min([h h-r]),max([1 1-c]):min([w w-c]),fr);
     
case 1
         % ��תƽ��У��
         cnst = 12; 
         theta = zeros(1,20);
         Mrs = uint8(zeros(size(M))); Mrs(:,:,1) = M(:,:,1);
         for fr=2:20
             B=[V(:,:,fr) + cnst*[-1 1; 1 1; -1 -1; 1 -1]]';B=B(:);
             A=zeros(2*4,4);
             A(1:2:end,1)=V(:,1,fr-1) + cnst*[-1 1 -1 1]';  %1st col
             A(2:2:end,1)=V(:,2,fr-1) + cnst*[1 1 -1 -1]';
             A(2:2:end,2)=V(:,1,fr-1) + cnst*[-1 1 -1 1]';  %2nd col
             A(1:2:end,2)=V(:,2,fr-1) - cnst*[1 1 -1 -1]';
             A(1:2:end,3)=1;          %3rd col
             A(2:2:end,4)=1;          %4th col
             X=A\B
             theta(fr)=atan2(X(1),X(2))*180/pi-90; theta(fr)
             Mrs(:,:,fr) = ...
                 imrotate(M(:,:,fr),sum(theta(1:fr)),'bilinear','crop');
             figure,imshow(Mrs(:,:,fr))
         end

     end
   
end 
close(hw) 
return
