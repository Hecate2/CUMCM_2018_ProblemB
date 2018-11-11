clear
load greedy2_3.mat;

ma=max(prod);
sLife=size(greedySolves,1);
lifeCount=sLife;

for i=1:1:sLife
    if(prod(i,1)/ma/0.9<1)%如果某生物贪婪算法的产量不到最强生物的90%，则将其产量设为0，意为淘汰之
        prod(i,1)=0;
        lifeCount=lifeCount-1;
    end
end

current=1;next=2;
%本来想把current叫做i，把next叫做j，但会被MATLAB理解成虚数单位
elimThreshold=0;%遇到贪婪产量比淘汰阈值elimThreshold低太多的生物，直接淘汰
while lifeCount>5   %这层while暂时没有用处
    %while current<=sLife-1
        if(prod(current,1)>elimThreshold*0.9) %比阈值的90%还低的，直接淘汰
            next=current+1;
            while next<=sLife
                if(prod(next,1)>elimThreshold*0.9)
                    keep=1;
                    while(keep==1)
                        if(prod(next,1)<prod(current,1))
                            %如果生物j的产量不如i，则给j进化机会。
                            %如果进化后j的产量仍然不如i，淘汰j
                            %如果进化后j的产量超过了i，则再给i进化机会。
                            %任何一方进化后仍不能获胜则被淘汰
                            elimThreshold=prod(next,1);%目前产量较低者的产量被记为阈值。
                            %如果之后遇上贪婪产量比elimThreshold低太多的生物，直接淘汰该生物
                            greedySolves{next,1}=evolve(CNC(next,:),{CNCcell{next,:}},greedySolves{next,1});
                            if(checkProduction(CNC(next,:),{CNCcell{next,:}},greedySolves{next,1})<=prod(current,1))
                                prod(next,1)=0;
                                lifeCount=lifeCount-1;
                                next=next+1;
                                keep=0;
                            end
                        else
                            elimThreshold=prod(current,1);%如果之后遇上贪婪产量比elimThreshold低太多的生物，直接淘汰该生物
                            greedySolves{current,1}=evolve(CNC(current,:),{CNCcell{current,:}},greedySolves{current,1});
                            if(checkProduction(CNC(current,:),{CNCcell{current,:}},greedySolves{current,1})<=prod(next,1))
                                prod(current,1)=0;
                                lifeCount=lifeCount-1;
                                current=next;
                                next=next+1;
                                keep=0;
                            end
                        end
                    end
                    %if()
                else
                    if(prod(next,1)>0)
                        lifeCount=lifeCount-1;
                    end
                    prod(next,1)=0;
                    next=next+1;
                end
            end
        else
            if(prod(current,1)>0)
                lifeCount=lifeCount-1;
            end
            prod(current,1)=0;
            current=next;
            next=next+1;
        end
    %end
end

solve=evolve(CNC(current,:),{CNCcell{current,:}},greedySolves{current,1});
current
checkProduction(CNC(current,:),{CNCcell{current,:}},greedySolves{current,1})
save('genetic2_3.mat');

function prod = checkProduction(CNC,cell,DNA)
%CNC输入哪台机器能加工哪道工序的行向量
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
reload=[27 32 27 32 27 32 27 32];
global work;
work=[455 182];%CNC第一道工序要400秒，第二道工序378秒。

wash=zeros(1,8);
for i=1:s(2)
    wash(cell{1,2}(1,i))=25;%只有从第2类机器下料时需要花时间清洗
end

remain=zeros(1,8);%每台机器剩余加工时间

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
while remainTime>0
    count=count+1;
    total=max(tm(j,:),remain)+reload+wash;%前往下一台CNC，装料，清洗所需总时间
    %下面检查前往的下一台机器类型是否正确，并求耗时
    if(CNC(1,DNA(1,count))~=nextCNCtype)
        prod=0;
        return
    end
    tmp=CNCloaded(DNA(1,count));
    %total(DNA(1,count));为这次RGV移动，上料，清洗所花时间
    prod=prod+nextCNCtype-1;%如果下次去2类CNC，则产量+1
    CNCloaded(DNA(1,count))=nextCNCtype;
    remainTime=remainTime-total(DNA(1,count));%RGV工作时总时间减少
    remain=max(remain-total(DNA(1,count)),[0 0 0 0 0 0 0 0]);%没有被RGV光顾的CNC继续工作直到自己剩余时间为0
    remain(DNA(1,count))=work(nextCNCtype)-wash(DNA(1,count));%被装料的CNC开始新一次工作。在物料清洗时被装料的CNC也在工作，因此当RGV又可动时这台CNC已经运行了清洗所需的时间
    j=DNA(1,count);
    nextCNCtype=3-tmp;
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

function evolution=evolve(CNC,cell,DNA)  %对指定的CNC安排方式，通过遗传变异使它的RGV选择顺序(DNA)进化
len=size(DNA,2)*2;
life=[
DNA DNA;
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
while generation<=500
    generation=generation+1;
    mi=10000;
    ma=-1;
    miIndex=1;maIndex=2;midIndex1=3;midIndex2=4;
    for i=1:s
        prod(i)=checkProduction(CNC,cell,life(i,:));  %prod意为product
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
    %life(midIndex1,:)=nextGen([life(maIndex,:);life(midIndex1,:)]);%两个链杂交
    life(midIndex2,:)=ceil(rand(1,len)*8);%随机重排
end

for i=1:s
    prod(i)=checkProduction(CNC,cell,life(i,:));  %prod意为product
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
evolution=life(maIndex,:);
end
