function plotELTseekers(hs,i)

YT = hs.STraj;
T = hs.T;
%     fvp  = find(YT(:,5)==1);
%     fpa2 = find(YT(:,7)==3);
%     fna2 = find(YT(:,2));
%     fpa1 = find(YT(:,6)==3);
%     fna1 = find(YT(:,1));
% Detect rising edges
fvp0  = YT(1:end-1,5)==1; fvp1 = (YT(2:end,5)==1);
fvp = find(fvp0==0 & fvp1==1)+1;
if (fvp0(1)==1 && fvp1(1)==0); fvp(1) = 1; end

fpa20  = YT(1:end-1,7)==3; fpa21 = (YT(2:end,7)==3);
fpa2 = find(fpa20==0 & fpa21==1)+1;
if (fpa20(1)==1 && fpa21(1)==0); fpa2(1) = 1; end

fna20  = YT(1:end-1,2)==1; fna21 = (YT(2:end,2)==1);
fna2 = find(fna20==0 & fna21==1)+1;
if (fna20(1)==1 && fna21(1)==0); fna2(1) = 1; end

fpa10  = YT(1:end-1,6)==3; fpa11 = (YT(2:end,6)==3);
fpa1 = find(fpa10==0 & fpa11==1)+1;
if (fpa10(1)==1 && fpa11(1)==0); fpa1(1) = 1; end

fna10  = YT(1:end-1,1)==1; fna11 = (YT(2:end,1)==1);
fna1 = find(fna10==0 & fna11==1)+1;
if (fna10(1)==1 && fna11(1)==0); fna1(1) = 1; end


titles = { 'NA1', 'NA2', 'NA3', 'Apace', 'Vpace', 'PA1', 'PA2'};
plotorder = [5,7,2,6,1];
nbsignals = length(plotorder);
figure(i)
ii=1;
for s=plotorder
    subplot(nbsignals+1,1,ii)
    plot(T,YT(:,s))
    title(titles{s})
    ii=ii+1;
end
subplot(nbsignals+1,1,2);
hold on;
plot(T(fpa2),YT(fpa2,7),'r*')
subplot(nbsignals+1,1,4);
hold on;
plot(T(fpa1),YT(fpa1,6),'r*')

IT = hs.InputSignal;
subplot(nbsignals+1,1,nbsignals+1)
plot(T,IT)
title('Input signal')

for jj=2:length(fvp)
    lend = fvp(jj-1);
    rend = fvp(jj);
    if T(rend) - T(lend) <= 600
        disp(['Difference ', num2str(i), ' at pulse ', num2str(jj),' is ',num2str( T(rend) - T(lend))])
        btwPA2 = find(fpa2 <= rend & fpa2 >= lend);
        btwNA2 = find(fna2 <= rend & fna2 >= lend);
        btwPA1 = find(fpa1 <= rend & fpa1 >= lend);
        btwNA1 = find(fna1 <= rend & fna1 >= lend);
        if ~isempty(btwPA2) && ~isempty(btwPA1) && ~isempty(btwNA2) && ~isempty(btwNA1)
            disp(['Check figure ',num2str(i) ' between ', num2str(T(lend)), ' and ' , num2str(T(rend))])
        end
    end
end
end