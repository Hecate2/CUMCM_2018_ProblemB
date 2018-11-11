clear

load genetic1_3.mat

out=zeros(size(result,2),3);%输出到excel表的矩阵。第1列为CNC编号，第2列为该CNC被上料时间，第3列为该CNC被下料时间

%tm矩阵表示RGV在两台CNC之间移动所需的时间(time for movement)
%例如tm(1,3)表示RGV从1号CNC移动到3号CNC所需的时间，在矩阵中为第1行第3列的值
tm=[
    0 0 18 18 32 32 46 46;
    0 0 18 18 32 32 46 46;
    18 18 0 0 18 18 32 32;
    18 18 0 0 18 18 32 32;
    32 32 18 18 0 0 18 18;
    32 32 18 18 0 0 18 18;
    46 46 32 32 18 18 0 0;
    46 46 32 32 18 18 0 0;
    ];
%reload(i)表示第i台CNC上料下料所需时间
reload=[27 32 27 32 27 32 27 32];
work=545;%CNC处理一个物料要560秒。

loadedNumber=[0 0 0 0 0 0 0 0];%每台CNC上载有的工件是第几件

j=1;%当前所在CNC
count=0;%目前已给CNC上料的累计次数
remainTime=8*3600;
%remain数列表示第i台CNC还需要remain(i)时间完成工作
remain=[0 0 0 0 0 0 0 0];
%wash表示上下料后物料清洗消耗的时间
%一开始所有CNC都空载，因此上下料后无需清洗。第i台机器完成上料后，wash(result(count))应变为25
wash=[0 0 0 0 0 0 0 0];
timer=0;
while remainTime>0
    count=count+1;
    total=max(tm(j,:),remain)+reload+wash;
    %result(count)为下一步要上料的CNC;%total(result(count))为这次移动和上料所花时间
    remainTime=remainTime-total(result(count));
    timer=timer+max(tm(j,result(count)),remain(result(count)));    %移动
    if (loadedNumber(result(count))~=0)%CNC上已有的工件被下料
        out(loadedNumber(result(count)),3)=timer;
    end
    out(count,1)=result(count);%第count件新工件上料
    out(count,2)=timer;
    loadedNumber(result(count))=count;
    timer=timer+reload(result(count))+wash(result(count));    %上料，清洗
    remain=max(remain-total(result(count)),[0 0 0 0 0 0 0 0]);%没有被装料的CNC继续工作直到自己剩余时间为0
    remain(result(count))=work-wash(result(count));%被装料的CNC开始新一次工作。在物料清洗时被装料的CNC也在工作，因此当RGV又可动时这台CNC已经运行了清洗所需的时间
    wash(result(count))=25;
    j=result(count);
end

save('simulation1_3.mat');
