function  [Ms,Va,Vg,V]  =  stabilizeMovie_GCBPM(M)
% 灰色编码算法
% 输入：M-待处视频
% 输出：Ms-稳定图像序列
%       Va-集成运动矢量
%       Vg-全局运动矢量
%       V-运动矢量
% 参考文献：
%      S. Ko, S. Lee, S. Jeon, and E. Kang. Fast digital image stabilizer
%      based on gray-coded bit-plane matching. IEEE Transactions on
%      Consumer Electronics, vol. 45, no. 3, pp. 598-603, Aug. 1999.
% 初始化全局变量
debug_disp = 0;                  

% 初始化算法的变量
bit = 5;                         % 最佳灰度编码位
N = 112;                         % 匹配块尺寸(设为NxN方块区域)
D1 = 0.95;                       % 消震系数(0 < D1 < 1)
logSearchEnable = 1;           % 1 采用logrigtmic 3-2-1 匹配搜索
                                 
nSteps = 3;                      % log search的步长，3个像素
rotEnable = 0;                   % 0 ，采用原始的转换GCBPM

[h,w,nFr] = size(M);             % 每一帧图像的宽度和长度
if ( ~rem(w,2) & ~rem(h,2) )
     S = uint8(zeros(h/2,w/2,2,4)); 
else
     error('video width/height must both be even # of pixels')
end
hw = waitbar(0,'Please wait...');
p = (h/2-N)/2;                   % 最大搜索窗位移
bxor = uint8(zeros(N));          % 中值
Cj = 1e9*ones(2*p+1);            % 相关测量
V = zeros(4,2,nFr);              % 运动矢量
Vg = zeros(nFr,2); %[0 0];       % 全局运动矢量
Va = zeros(nFr,2);               % 集成运动矢量
Ms = uint8(zeros(h,w,nFr));      % 初始化稳定图像序列
 
% 循环处理每一帧图像
for fr = 1:nFr
     waitbar((fr-1)/nFr,hw) % 显示过程
% 获得灰度编码位平面
     [Mg] = uint8(getGrayCodeBitPlane(M,bit,fr,debug_disp));
  
     S(:,:,2,1) = Mg( 1:h/2,       1:w/2        ); % UL, S1
     S(:,:,2,2) = Mg( 1:h/2,       w/2+1:end    ); % UR, S2
     S(:,:,2,3) = Mg( h/2+1:end,  1:w/2        ); % LL, S3
     S(:,:,2,4) = Mg( h/2+1:end,  w/2+1:end    ); % LR, S4
   
     if fr > 1 % 在第一帧图像之后运用算法
       
         for j = 1:4 % 循环处理每一幅子图像
             if ~logSearchEnable
                 % 精确搜索
                 for m_pos = 1:2*p+1 % 循环处理每一个可能的位移
                     for n_pos = 1:2*p+1
                       
                         % 计算相关性度量
                         bxor = bitxor( ...  
                             S(p+1:p+N,p+1:p+N,2,j) , ...
                             S(m_pos:m_pos+N-1,n_pos:n_pos+N-1,1,j) );
                         Cj(m_pos,n_pos) = sum(bxor(:)); 
                       
                     end
                 end 
         % 查找最小的Cj位置
                 [tmp,m_pos_min] = min(Cj);
                 [tmp,n_pos_min] = min(tmp); clear tmp;
                 m_pos_min=m_pos_min(n_pos_min);
             else
                 % log搜索
                 %  注：处理图像的像素为256x256 
                 firstJmp = 4;
                 prev_m_pos = 9; prev_n_pos = 9; % 从中心开始
                 for iter = 1:nSteps
                     
                     Cj = 1e9*ones(2*p+1); % 重置相关度量
                     curJmp = firstJmp./2.^(iter-1);
                     for m_pos = prev_m_pos-curJmp:curJmp:prev_m_pos+curJmp
                         for n_pos = prev_n_pos-curJmp:curJmp:prev_n_pos+curJmp
                           
                             % 计算相关度量
                             bxor = bitxor( ...  % could be very fast HW
                                 S(p+1:p+N,p+1:p+N,2,j) , ...
                                S(m_pos:m_pos+N-1,n_pos:n_pos+N-1,1,j) );
                             Cj(m_pos,n_pos) = sum(bxor(:));
                           
                         end
                     end
 
                     %  查找最小的Cj位置                   
[tmp,m_pos_min] = min(Cj);
                     [tmp,n_pos_min] = min(tmp); clear tmp;
                     m_pos_min=m_pos_min(n_pos_min);
                    
                     prev_m_pos = m_pos_min;
                     prev_n_pos = n_pos_min;
                   
                 end                
             end 
             V(j,:,fr) = [m_pos_min n_pos_min]-p-1; % V[1] V[2]
         end 
         % 计算当前全局运动矢量
         Vg(fr,:) = median([V(:,:,fr);Vg_prev]);
       
         % 运用消震来产生这一帧的全局运动矢量
         Va(fr,:) = D1 * Va_prev + Vg(fr,:);
       
     end 
 
     % 存储当前帧图像为上一帧图像
     S(:,:,1,:) = S(:,:,2,:);     % 灰度编码自图像
     Vg_prev = Vg(fr,:);          % 全局运动矢量
     Va_prev = Va(fr,:);          % 集成运动矢量
     
     switch rotEnable
     case 0
         % 平移校正
         %  (not sub-pixel for now)
         r = round(Va(fr,1)); % num rows moved
         c = round(Va(fr,2)); % num columns moved
         Ms(max([1 1+r]):min([h h+r]),max([1 1+c]):min([w w+c]),fr) = ...
             M(max([1 1-r]):min([h h-r]),max([1 1-c]):min([w w-c]),fr);
     
case 1
         % 旋转平移校正
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
