%%Time: 2017.9.17
%%Name:Michael Beechan(陈兵)
%%School:Chongqing university of technology

% mixture of Gaussians algorithm for background
%混合高斯模型适用于相机固定的运动目标检测，光流法适用于相机运动的运动目标检测


close all;
clear all;
source=dir('*.jpg');




% -----------------------  frame size variables -----------------------
% read in 1st frame as background frame
fr_bw=imread(source(1).name);
%fr_bw = rgb2gray(fr);     % convert background to greyscale
fr_size = size(fr_bw);             
width = fr_size(2);
height = fr_size(1);
fg = zeros(height, width);
bg_bw = zeros(height, width);


% --------------------- mog variables -----------------------------------


C = 3;                                  % number of gaussian components (typically 3-5)   Cgegaosimoxing
M = 3;                                  % number of background components,
D = 2.5;                                % positive deviation threshold
alpha = 0.01;                           % learning rate (between 0 and 1) (from paper 0.01) the background will change slowly with the time, so the mean(u)should be updated slowly.
thresh = 0.25;                          % foreground threshold (0.25 or 0.75 in paper)
sd_init = 6;                            % initial standard deviation (for new components) var = 36 in paper
w = zeros(height,width,C);              % initialize weights array
mean = zeros(height,width,C);           % pixel means  , the u of gaosi(u,d)
sd = zeros(height,width,C);             % pixel standard deviations , the d of gaosi(u,d)
u_diff = zeros(height,width,C);         % difference of each pixel from mean
p = alpha/(1/C);                        % initial p variable (used to update mean and sd)
rank = zeros(1,C);                      % rank of components (w/sd)


% --------------------- initialize component means and weights -----------


pixel_depth = 8;                        % 8-bit resolution
pixel_range = 2^pixel_depth -1;         % pixel range (# of possible values)


for i=1:height
    for j=1:width
        for k=1:C
            
            mean(i,j,k) = rand*pixel_range;     % means random (0-255)
            w(i,j,k) = 1/C;                     % weights uniformly dist
            sd(i,j,k) = sd_init;                % initialize to sd_init
            
        end
    end
end


%--------------------- process frames -----------------------------------


for n = 8:(length(source)-2)              %there will be false route line,so it only include the pictures which has the car


    fr_bw = imread(source(n).name);       % read in frame
    %fr_bw = rgb2gray(fr);       % convert frame to grayscale
    
    % calculate difference of pixel values from mean
    for m=1:C
        u_diff(:,:,m) = abs(double(fr_bw) - double(mean(:,:,m)));
    end
    sum_x=0;
    sum_y=0;
    num=0; 
    % update gaussian components for each pixel
    for i=1:height                        %%%%%%%%%%%%%search each pixal of one image, if it is in the C ge gaosimoxing, it is belong to the background,and undate the background.
        for j=1:width                     %%%%%%%%%% If it is not in the C ge gaosimoxing, create a new gaosi and replace the least possible gaosi. Finally the the first several gaosi is background, and the last several is foreground 
                                                
            match = 0;            
                                          
            for k=1:C                       
                if (abs(u_diff(i,j,k)) <= D*sd(i,j,k))       % pixel matches component
                    
                    match = 1;                          % variable to signal component match
                    
                    % update weights, mean, sd, p
                    w(i,j,k) = (1-alpha)*w(i,j,k) + alpha;
                    p = alpha/w(i,j,k);                  
                    mean(i,j,k) = (1-p)*mean(i,j,k) + p*double(fr_bw(i,j));
                    sd(i,j,k) =   sqrt((1-p)*(sd(i,j,k)^2) + p*((double(fr_bw(i,j)) - mean(i,j,k)))^2);
                else                                    % pixel doesn't match component
                    w(i,j,k) = (1-alpha)*w(i,j,k);      % weight slighly decreases
                    
                end
            end
            
                  
            bg_bw(i,j)=0;
            for k=1:C
                bg_bw(i,j) = bg_bw(i,j)+ mean(i,j,k)*w(i,j,k);
            end
            
            % if no components match, create new component
            if (match == 0)
                [min_w, min_w_index] = min(w(i,j,:));  
                mean(i,j,min_w_index) = double(fr_bw(i,j));
                sd(i,j,min_w_index) = sd_init;
            end


            rank = w(i,j,:)./sd(i,j,:);             % calculate component rank
            rank_ind = [1:1:C];
            


            % calculate foreground
            fg(i,j) = 0;
            while ((match == 0)&&(k<=M))
 
                    if (abs(u_diff(i,j,rank_ind(k))) <= D*sd(i,j,rank_ind(k)))
                        fg(i,j) = 0; %black = 0
           
                    else
                        fg(i,j) = fr_bw(i,j);                  
                        sum_x=sum_x+j;        
                        sum_y=sum_y+i;
                        num=num+1;
                    end   
                k = k+1;                
            end
            
        end
    end
    
   
    if n==8||n==9||n==10
        route_x=[round(sum_x/num),round(sum_x/num)];
        route_y=[round(sum_y/num),round(sum_y/num)];
    else


        next_x=round(sum_x/num);
        next_y=round(sum_y/num);
        route_x=[route_x,next_x];
        route_y=[route_y,next_y];
    end
    num=0;
    figure(1);
    %subplot(3,1,1);    
    imshow(fr_bw);
    title('原始图像');
    figure(2);
    %subplot(3,1,2);    
    imshow(uint8(bg_bw));
    title('背景图像');
    figure(3);
    %subplot(3,1,3);  
    imshow(uint8(fg)); 
    %hold on;
    %plot(route_x,route_y,'LineWidth',1,'Color','r');
    title('前景图像');
    frameNum = 270 + n;     %这里的0表示截取的开始帧数
    path='D:\数学建模代码\问题2\动态背景\gaosi';
    imwrite(fg,strcat(path,int2str(frameNum),'.jpg'));
  
    
    %Mov1(n)  = im2frame(uint8(fg),gray);           % put frames into movie
    %Mov2(n)  = im2frame(uint8(bg_bw),gray);           % put frames into movie
    
end
      
%movie2avi(Mov1,'mixture_of_gaussians_output','fps',30);           % save movie as avi 
%movie2avi(Mov2,'mixture_of_gaussians_background','fps',30);           % save movie as avi 