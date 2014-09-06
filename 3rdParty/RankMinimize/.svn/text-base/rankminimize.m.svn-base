%contour: cells of the contours
%hankelszie: col number of the hankel matrix
%Size: Size of the image
%lambda: parameter to affect the smooth strength

function contour_clean = rankminimize(contour, hankelsize, Size, lambda)
% lambda=5;
xx=round(Size(1)/2);
yy=round(Size(2)/2);
for(k=1:length(contour))
    contourz=contour{k};
    trjx=contourz(:,1)';
    trjy=contourz(:,2)';
    
    trjx=trjx-xx;
    trjy=trjy-yy;
    
    trjx=trjx/xx;
    trjy=trjy/yy;
    
    trj=[trjx;trjy];
    trj=trj(:);
    
    cc=find(~isnan(trjx));
    horizon=cc(end)-cc(1)+1;
    
    datacomx=trjx(cc(1):cc(end));
    datacomy=trjy(cc(1):cc(end));
    if horizon>2*hankelsize
        Hcomx=hankelConstruction(datacomx,hankelsize);
        Hcomy=hankelConstruction(datacomy,hankelsize);
    else
        Hcomx=hankel(datacomx(1:round(horizon/2)),datacomx(round(horizon/2):horizon));
        Hcomy=hankel(datacomy(1:round(horizon/2)),datacomy(round(horizon/2):horizon));
    end
    Hcom=[Hcomx; Hcomy];
    size(Hcom);
    
    [~,~,val,rnk,a,e]=rHPCA_weight_reweighted_simpler_2D(Hcom,lambda,ones(1,size(datacomx,2)));
    
    datacomx_clean=a(1:end/2);
    datacomy_clean=a(end/2+1:end);
    
    datacomx_clean=(datacomx_clean*xx)+xx;
    datacomy_clean=(datacomy_clean*yy)+yy;
    
    contourz_clean(:,1)=datacomx_clean;
    contourz_clean(:,2)=datacomy_clean;
    
    contour_clean{k}=contourz_clean;
    contourz_clean=[];
    if mod(k,100) == 0
        disp(k)
    end
end
