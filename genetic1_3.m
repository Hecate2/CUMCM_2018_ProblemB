clear
%遗传算法
%有4个生物，每个生物380个基因DNA决定CNC选择顺序
%要判断这个生物质量的好坏，只要看前多少个基因用完了8小时，即8小时生产多少东西

%total数列表示RGV从现在停泊的CNC出发，如果下一步前往第i台CNC为其装料，则total(i)时间后RGV才能再次行动
%（包括RGV移动时间，CNC工作时间和下料后清洗时间）
%total=tm(1,:)+reload;%这是初始状态
%假设RGV正从第j台CNC出发，则total的公式为:
%total=max(tm(j,:),remain)+reload+wash;
%移动时间和机器剩余工作时间的最大值，加上上下料时间和清洗时间
j=1;    %设RGV当前位置在第j台CNC。一开始RGV在第1台CNC位置

count=0;%RGV一共进行了count次上下料
%假设RGV下一步前往第i台CNC

%计算到达每个CNC，为其装料，清洗物料所需时间
% total=max(tm(j,:),remain)+reload+wash;
% remainTime=remainTime-mi;
% remain=max(remain-mi,[0 0 0 0 0 0 0 0]);%没有被装料的CNC继续工作直到自己剩余时间为0
% remain(i)=work-wash(i);%被装料的CNC开始新一次工作。在物料清洗时被装料的CNC也在工作，因此当RGV又可动时这台CNC已经运行了清洗所需的时间
% wash(i)=25;
% result(count)=i;

%定义7个生物的DNA链
load greedy1_3.mat
len=size(result,2)+20;
life=[
result ceil(rand(1,20)*8);
ceil(rand(1,len)*8);
ceil(rand(1,len)*8);
ceil(rand(1,len)*8);
ceil(rand(1,len)*8);
ceil(rand(1,len)*8);
ceil(rand(1,len)*8);
];
s=size(life,1);

generation=0;
prod=zeros(s,1);
while generation<=5000
    generation=generation+1;
    mi=10000;
    ma=-1;
    miIndex=1;maIndex=2;midIndex1=3;midIndex2=4;
    for i=1:s
        prod(i)=checkProduction(life(i,:));  %prod意为product
        if mi>prod(i)
            %midIndex1=miIndex;
            miIndex=i;
            mi=prod(i);
        end
        if ma<prod(i)
            %midIndex2=maIndex;
            maIndex=i;
            ma=prod(i);
        end
    end
    %上面maIndex标记最高产量的链，miIndex标记最低产量的链，两个midIndex标记其他任意两个链
    while(midIndex1==maIndex || midIndex1==miIndex)
        midIndex1=unidrnd(s);
    end
    while(midIndex2==maIndex || midIndex2==miIndex || midIndex2==midIndex1)
        midIndex2=unidrnd(s);
    end
    %遗传进化
    life(miIndex,:)=changeDNA(life(maIndex,:));%最差产量的链修改为最高产量的链的变异
    life(midIndex1,:)=nextGen([life(maIndex,:);life(midIndex1,:)]);%两个链杂交
    life(midIndex2,:)=ceil(rand(1,len)*8);%随机重排
end

for i=1:s
    prod(i)=checkProduction(life(i,:));  %prod意为product
    if mi>prod(i)
        midIndex1=miIndex;
        miIndex=i;
        mi=prod(i);
    end
    if ma<prod(i)
        midIndex2=maIndex;
        maIndex=i;
        ma=prod(i);
    end
end
result=life(maIndex,:);
save('genetic1_3.mat','result');
prod(maIndex)


function production = checkProduction(DNA)
    %tm矩阵表示RGV在两台CNC之间移动所需的时间(time for movement)
    %例如tm(1,3)表示RGV从1号CNC移动到3号CNC所需的时间，在矩阵中为第1行第3列的值
global tm;
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
global reload;
reload=[28 31 28 31 28 31 28 31];
global work;
work=545;%CNC处理一个物料要545秒。

    j=1;%当前所在CNC
    production=0;%目前已给CNC上料的累计次数
    remainTime=8*3600;
    %remain数列表示第i台CNC还需要remain(i)时间完成工作
    remain=[0 0 0 0 0 0 0 0];
    %wash表示上下料后物料清洗消耗的时间
    %一开始所有CNC都空载，因此上下料后无需清洗。第i台机器完成上料后，wash(DNA(production))应变为25
    wash=[0 0 0 0 0 0 0 0];
    while remainTime>=0
        production=production+1;
        total=max(tm(j,:),remain)+reload+wash;
        %DNA(production)为下一步要上料的CNC;%total(DNA(production))为这次移动和上料所花时间
        remainTime=remainTime-total(DNA(production));
        remain=max(remain-total(DNA(production)),[0 0 0 0 0 0 0 0]);%没有被装料的CNC继续工作直到自己剩余时间为0
        remain(DNA(production))=work-wash(DNA(production));%被装料的CNC开始新一次工作。在物料清洗时被装料的CNC也在工作，因此当RGV又可动时这台CNC已经运行了清洗所需的时间
        wash(DNA(production))=25;
        j=DNA(production);
    end
end

function child=nextGen(parents)%输入2行n列矩阵，每行是一个作为parent的生物，每个生物的DNA有n个
    %parents=[chain1;chain2];
    s=size(parents,2);
    child=zeros(1,s);
    for i=1:s
        child(i)=parents(unidrnd(2),i);
    end
end

function evolution=changeDNA(life)%输入一个生物的1行n列DNA链，每个DNA有1%概率突变
    s=size(life,2);
    evolution=rand(1,s);
    for i=1:s
        if(evolution(i)<=0.99)
            evolution(i)=life(i);
        else
            evolution(i)=unidrnd(8);
        end
    end
end
