 % load hall files
 clear
 load hall;
 T=double(T);
 In = size(T); % 3D tensor
 %% Estimate affine global motion with 6?parameters
 iters = [5,3,3];
 M = zeros(3,3,In(3));
 for k = 1:In (3)
 M(:,:,k) = estMotionMulti2(T(:,:,1),T(:,:,k),iters ,[],1,1);
 end
 %% Inverse affine transform and build new tensor
 Tnew = T;
 for k = 2:In (3)
 Tnew(:,:,k) = warpAffine2(T(:,:,k),M(:,:,k));
 end
 %% Process all sub?blocks
 sT = size(T);blksz = 8;
 d = zeros(sT(end),prod(sT (1:2))/ blksz ^2);
 kblk = 0; thresh = 0.005;
 xy = zeros(1,2);
 Imbgr = zeros(sT(1:2));
 for xu = 1:8: sT(1)-7
 for yu = 1:8: sT(2)-7
 kblk = kblk + 1;
 Tblk = Tnew(xu:xu+blksz-1, yu:yu+blksz-1,:);
 nanind = find(isnan(Tblk));
 [r,c,nanfr] = ind2sub(size(Tblk),nanind);
 Tblknew = Tblk(:,:,setdiff (1:sT(end),unique(nanfr )));
 %% Factorize subtensor with Parafac algorithms R = 1
 Yblk = permute(tensor(Tblknew),[3 1 2 ]);
 A_= cp_als(Yblk ,1);
 d = full( A_{1});

 edges = [min(d): thresh:max(d) max(d)+eps] ;
 [n,bin] = histc(d ,edges);
 m = mode(bin);
 indbgr = find ((d >= edges(m)) & (d <= edges(m+1)));
 Imbgr(xu:xu+blksz-1,yu:yu+blksz-1)=median(Tblknew(:,:,indbgr),3);
 end
 end
 %% Display the estimated background image
 imshow(uint8(Imbgr))