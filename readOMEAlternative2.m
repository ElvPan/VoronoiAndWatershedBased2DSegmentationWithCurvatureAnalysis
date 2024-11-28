function [datas,meta]=readOMEAlternative2(name);

%%
data=bfopen(name);
meta=GetOMEData(name);
omeMeta = data{1, 4};
numch=omeMeta.getChannelCount(0);

clear ss
for i=1:size(data,1)
    t=data{i,1};
    ss(i)=size(t,1);
end

indSeries=find(ss==max(ss));

for j=1:numch
    for i=1:ss(indSeries)/numch
  datas(:,:,j,i)=data{indSeries,1}{j+(i-1)*numch,1};
    end
end

datas=squeeze(datas);