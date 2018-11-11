clear

load genetic2_1.mat
result=greedySolves{current,1};
cell={CNCcell{current,:}};
CNC=CNC(current,:);

out=zeros(size(result,2),6);%输出到excel表的矩阵。第1列为CNC编号，第2列为该CNC被上料时间，第3列为该CNC被下料时间

%cell必须输入一个1×2元胞数组cell，cell{1,1}为第1类CNC（加工第1道工序）的1×n编号集合（数列），cell{1,2}为第2类CNC的编号集合
%DNA输入RGV选择CNC的顺序
%输出prod为产量
s=[size(cell{1,1},2),size(cell{1,2},2)];
%每个元胞里数列的大小都不可以是0
% if (s(1)==0 || s(2)==0)
%     greedySolve=zeros(1,8);
%     return;
% end
%tm矩阵表示RGV在两台CNC之间移动所需的时间(time for movement)
%例如tm(1,3)表示RGV从1号CNC移动到3号CNC所需的时间，在矩阵中为第1行第3列的值
tm=[
    0 0 20 20 33 33 46 46;
    0 0 20 20 33 33 46 46;
    20 20 0 0 20 20 33 33;
    20 20 0 0 20 20 33 33;
    33 33 20 20 0 0 20 20;
    33 33 20 20 0 0 20 20;
    46 46 33 33 20 20 0 0;
    46 46 33 33 20 20 0 0;
];
%reload(i)表示第i台CNC上料下料所需时间
reload=[28 31 28 31 28 31 28 31];
work=[400 378];%CNC第一道工序要400秒，第二道工序378秒。

wash=zeros(1,8);
for i=1:s(2)
    wash(cell{1,2}(1,i))=25;%只有从第2类机器下料时需要花时间清洗
end

remain=zeros(1,8);%每台机器剩余加工时间

RGVcarrying=1;%RGV上携带的物料是第几个
code=0;%最新一个物料
loadedNumber=[0 0 0 0 0 0 0 0];%每台CNC上载有的工件是第几件

j=1;%当前所在CNC
remainTime=8*3600;%记录剩余时间
count=0;%RGV一共进行了count次上下料
prod=0;%记录产量（给2上料一次则产量+1）
nextCNCtype=1;%标记RGV下一次应找哪种CNC
%判断下次可做哪道工序的规则：
%情况0：一开始应做第1道工序（显然）
%情况1：如果刚才给一个无载荷的1类CNC上下料，则上下料完成后RGV手里没有任何东西，因此应当继续找一个1类CNC
%情况2：如果刚才给一个有载荷的1类CNC上下料，则上下料完成后RGV手里有一个应该交给2类CNC的熟料
%情况3：如果刚才给一个2类CNC上下料，则上下料完成后CNC手里没有任何东西，应找一个1类CNC
%理论上RGV手里没有东西时，下一步既可以找1类CNC上下料，也可以继续给2类CNC下料，但是找2类CNC并不会节约任何时间。
CNCloaded=2*ones(1,8);%记录CNC下一次被下料后RGV上装着何种物料。2表示小车上不会有物料。1表示小车上会有经过第1道工序的熟料
timer=0;
while remainTime>0
    count=count+1;
    total=max(tm(j,:),remain)+reload+wash;%前往下一台CNC，装料，清洗所需总时间
    %下面检查前往的下一台机器类型是否正确
    if(CNC(1,result(1,count))~=nextCNCtype)
        prod=0;
        return
    end
    
    if(nextCNCtype==1)
        code=code+1;
        RGVcarrying=code;
    end
    
    timer=timer+max(tm(j,result(1,count)),remain(result(1,count)));

    %记录上下料
    out(RGVcarrying,nextCNCtype*3-2)=result(1,count);
    out(RGVcarrying,nextCNCtype*3-1)=timer;
    if(loadedNumber(result(1,count))~=0)
        out(loadedNumber(result(1,count)),nextCNCtype*3)=timer;
    end
    
    %CNC上装载物与RGV上装载物交换
    tmpRGV=loadedNumber(result(1,count));
    loadedNumber(result(1,count))=RGVcarrying;
    if(nextCNCtype==1)
        RGVcarrying=tmpRGV;
    else
        RGVcarrying=0;
    end

    timer=timer+reload(result(1,count))+wash(result(1,count));

    tmp=CNCloaded(result(1,count));
    %total(result(1,count));为这次RGV移动，上料，清洗所花时间
    prod=prod+nextCNCtype-1;%如果下次去2类CNC，则产量+1
    CNCloaded(result(1,count))=nextCNCtype;
    
    remainTime=remainTime-total(result(1,count));%RGV工作时总时间减少
    remain=max(remain-total(result(1,count)),[0 0 0 0 0 0 0 0]);%没有被RGV光顾的CNC继续工作直到自己剩余时间为0
    remain(result(1,count))=work(nextCNCtype)-wash(result(1,count));%被装料的CNC开始新一次工作。在物料清洗时被装料的CNC也在工作，因此当RGV又可动时这台CNC已经运行了清洗所需的时间
    j=result(1,count);
    nextCNCtype=3-tmp;
end

save('simulation2_1.mat');