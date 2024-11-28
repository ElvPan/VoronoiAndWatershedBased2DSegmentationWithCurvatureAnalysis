function [bigmycolors]=ColorMapPtPattern(StrengthMatrix);
%%
%%StrengthMatrix=allLifetimes_filt(:,1)';
%find how many unique LofR to plot
uStrengthMatrix=unique(StrengthMatrix);
% ind=find(~isnan(uStrengthMatrix));
% uStrengthMatrix=uStrengthMatrix(ind);
del=max(uStrengthMatrix)-min(uStrengthMatrix);
rangecol=(min(uStrengthMatrix):del/254:max(uStrengthMatrix));
mycolors=jet(255); %how many unique LofR value this many colors for data points

%%%%%%%%%%%%% sort LofR and make colormap for color plot...blue to red LofR
%%%%%%%%%%%%% increases.....
bigStrengthMatrix=repmat(StrengthMatrix,[length(rangecol) 1]);
bigCol=repmat(rangecol,[length(StrengthMatrix) 1])';
bigDiff=bigStrengthMatrix-bigCol;
bigDiff(find(bigDiff<=0))=NaN;
[vx,vy,v]=find(diff(isnan(bigDiff),1,1)>0);
indmycolors=ones(1,length(StrengthMatrix));
indmycolors(vy)=vx;
bigmycolors=zeros(length(StrengthMatrix),3);

for i=1:length(StrengthMatrix)
bigmycolors(i,:)=mycolors(indmycolors(i),:);
end
