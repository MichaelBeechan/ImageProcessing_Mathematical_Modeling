function  [Mg]  =  getGrayCodeBitPlane(M,bit,fr,debug_disp)
% 功能：计算输入图像的灰度编码位平面

if  debug_disp
     msb = 8;
     lsb = 1;
else
     msb = min([bit+1 8]);
     lsb = bit;
end
 
w = length(M(1,:,1)); % 宽
h = length(M(:,1,1)); % 高
M1bit = zeros(h,w,8);
M1bitGray  =  zeros(size(M1bit));
for b = msb:-1:lsb
     % 计算原始位平面(1是LSB, 8 是MSB)
     M1bit(:,:,b) = bitget(M(:,:,fr),b); % fr'th frame
     % 计算灰度编码位平面
     if b==8 % MSB
         M1bitGray(:,:,b) = M1bit(:,:,b);
     else % LSB
         M1bitGray(:,:,b) = bitxor(M1bit(:,:,b),M1bit(:,:,b+1));
     end
end
 
Mg =  M1bitGray(:,:,bit);
if  debug_disp
     for b = 8:-1:1
         figure,imshow(M(:,:,fr),[0 255]) 
         figure,set(gcf,'name',sprintf('Bit-Plane for bit # %d',b))
         imshow(M1bit(:,:,b)) 
         figure,set(gcf,'name',sprintf('Gray Bit-Plane for bit # %d',b))
         imshow(M1bitGray(:,:,b)) 
     end
end
return
