clear

%CNC矩阵第k行j列表示第k个生物的第j台机器可加工哪一道工序（1或2）
%CNC矩阵有2^8=256行，穷举8台CNC能加工的工序的所有情况
CNC=ones(256,8);
for i=2:1:256
    CNC(i,:)=CNC(i-1,:);
    CNC(i,8)=CNC(i,8)+1;
    for j=8:-1:1
        if(CNC(i,j)==3)
            CNC(i,j)=1;
            CNC(i,j-1)=CNC(i,j-1)+1;
        else
            break;
        end
    end
end
%其中第1行（所有CNC都只能加工第1工序）和第256行（所有CNC都只能加工第1工序）显然是不可能采用的。将无视这两种情况
%然后生成CNC1元胞数组和CNC2元胞数组。
%CNCcell的含义：在第k种CNC安排方案中（对应CNC矩阵第k行），可以加工第1道工序的所有机器编号放在CNCcell{k}{1}中。
CNCcell=cell(256,2);
for i=1:1:256
    for j=1:1:8
        CNCcell{i,CNC(i,j)}(size(CNCcell{i,CNC(i,j)},2)+1)=j;
    end
end
prod=zeros(256,10);%记录产量。由于每次机器损坏是随机的，所以记录10次
%接下来对于每一种CNC的安排，用贪婪算法求一个解
greedySolves=cell(256,1);%虽然安排了256行，但第1行和最后一行会被无视
for i=2:1:255
%for i=173:1:255 %用于从第173种情况开始做测试
    for k=1:1:size(prod,2)
        [prod(i,k),greedySolves{i,1}]=greedy2({CNCcell{i,1},CNCcell{i,2}});
    end
end

avgProd=mean(prod,2);
plot(avgProd);
xlim([1 256]);
save('problem3_2_1.mat');
[prod,index]=max(avgProd);

CNC=CNC(index,:);
cell={CNCcell{index,:}};
s=[size(cell{1,1},2),size(cell{1,2},2)];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%下面开始对选中的CNC方案进行模拟生产
out=zeros(420,6);
damage=zeros(100,4);

%CNC损坏的原则：
%每台CNC每做1次加工就有1%概率损坏
%若RGV决定下一次前往第i台机器，则立即用随机数决定这台机器是否要损坏，并赋予它一个维修剩余时间

%模型现存缺陷：若RGV在前往第i台CNC的过程中，该CNC突然损坏，则RGV该怎么做？
%由于RGV移动的距离与所花时间不是线性关系，因此难以模拟RGV在“半路上”改变移动目标所额外消耗的时间
%目前做出的假设是：如果RGV前往第i台CNC的过程中该CNC突然损坏，则RGV能够提前预知这一损坏，不前往该CNC，以避免RGV移动耗时不可知的情况

%调度策略：按贪婪方式调度RGV，但RGV不会前往目前正在修理的CNC。RGV在前往第i台CNC时若该CNC突然损坏，则RGV可以提前预知该损坏，且不前往该CNC

%tm矩阵表示RGV在两台CNC之间移动所需的时间(time for movement)
%例如tm(1,3)表示RGV从1号CNC移动到3号CNC所需的时间，在矩阵中为第1行第3列的值
tm=[
    0 0 23 23 41 41 59 59;
    0 0 23 23 41 41 59 59;
    23 23 0 0 23 23 41 41;
    23 23 0 0 23 23 41 41;
    41 41 23 23 0 0 23 23;
    41 41 23 23 0 0 23 23;
    59 59 41 41 23 23 0 0;
    59 59 41 41 23 23 0 0;
    ];

%reload(i)表示第i台CNC上料下料所需时间
reload=[30 35 30 35 30 35 30 35];
remainTime=8*3600;
work=[280 500];%CNC第一道工序要400秒，第二道工序378秒。
nextCNCtype=1;
CNCloaded=2*ones(1,8);

RGVcarrying=1;%RGV上携带的物料是第几个
code=0;%最新一个物料
loadedNumber=[0 0 0 0 0 0 0 0];%每台CNC上载有的工件是第几件

j=1;    %设RGV当前位置在第j台CNC。一开始RGV在第1台CNC位置
count=0;%RGV一共进行了count次上下料
damageCount=0;%一共出现过几次损坏
remain=[0 0 0 0 0 0 0 0];%每台CNC还有多长时间准备好下一次上下料(包括完成加工和完成修复)
damaged=[0 0 0 0 0 0 0 0];%CNC是否坏了。没坏的取0，坏了的可取非0的任意数
wash=zeros(1,8);
for i=1:s(2)
    wash(cell{1,2}(1,i))=30;%只有从第2类机器下料时需要花时间清洗
end
loadedNumber=[0 0 0 0 0 0 0 0];
timer=0;

while remainTime>0
    count=count+1;
    total=max(tm(j,:),remain)+reload+wash;%前往下一台CNC，装料，清洗所需总时间
    %下面求前往下一台类型正确的机器的耗时最小值，以及这台机器编号
    mi=total(cell{1,nextCNCtype}(1,1));
    i=cell{1,nextCNCtype}(1,1);
    for k=2:s(nextCNCtype)
        if(mi>total(cell{1,nextCNCtype}(1,k)))
            mi=total(cell{1,nextCNCtype}(1,k));
            i=cell{1,nextCNCtype}(1,k);
        end
    end
    %现在去第i台机器是最快的
    %下面检查前往的下一台机器类型是否正确
    if(CNC(1,i)~=nextCNCtype)
        prod=0;
        return
    end
    
    if(nextCNCtype==1)
        code=code+1;
        RGVcarrying=code;
    end
    
    timer=timer+max(tm(j,i),remain(i));

    %记录上下料
    out(RGVcarrying,nextCNCtype*3-2)=i;
    out(RGVcarrying,nextCNCtype*3-1)=timer;
    if(loadedNumber(i)~=0)
        out(loadedNumber(i),nextCNCtype*3)=timer;
    end
    
    %CNC上装载物与RGV上装载物交换
    tmpRGV=loadedNumber(i);
    loadedNumber(i)=RGVcarrying;
    if(nextCNCtype==1 && tmpRGV~=0)
        RGVcarrying=tmpRGV;
    elseif(nextCNCtype==1 && tmpRGV==0)
        RGVcarrying=tmpRGV;
        CNCloaded(i)=2;
    else
        RGVcarrying=0;
    end

    timer=timer+reload(i)+wash(i);
    ranDamage=rand(1);%随机决定第i台CNC在这次工作中是否会损坏
    if(ranDamage>0.99)
        workTime=unidrnd(work(nextCNCtype))-1;%正常工作的时间（工作了这么多时间后损坏），取值范围为闭区间[0,work-1]（完成加工所需时间减1）
        repairTime=unidrnd(10*60+1)+10*60-1;%修复时间取值范围为闭区间[10分钟,20分钟]
        remain(i)=workTime+repairTime-wash(i);
        %在为第i台CNC装料完成后，RGV清洗时CNC也在工作，因此当RGV又可动时这台CNC已经运行了清洗所需的时间
        wash(i)=0;%下次为该CNC下料时不需要清洗
        CNCloaded(i)=2;
        damaged(i)=1;
        damageCount=damageCount+1;
        damage(damageCount,1)=loadedNumber(i);
        loadedNumber(i)=0;
        damage(damageCount,2)=i;
        damage(damageCount,3)=timer+workTime-wash(i);
        damage(damageCount,4)=timer+workTime+repairTime-wash(i);
        if(nextCNCtype==2)
            prod=prod-1;
        end
    else
        remain(i)=work(nextCNCtype)-wash(i);
        damaged(i)=0;
    end

    tmp=CNCloaded(i);
    %total(i);为这次RGV移动，上料，清洗所花时间
    prod=prod+nextCNCtype-1;%如果下次去2类CNC，则产量+1
    CNCloaded(i)=nextCNCtype;
    
    remainTime=remainTime-total(i);%RGV工作时总时间减少
    remain=max(remain-total(i),[0 0 0 0 0 0 0 0]);%没有被RGV光顾的CNC继续工作直到自己剩余时间为0
    remain(i)=work(nextCNCtype)-wash(i);%被装料的CNC开始新一次工作。在物料清洗时被装料的CNC也在工作，因此当RGV又可动时这台CNC已经运行了清洗所需的时间
    nextCNCtype=3-tmp;
    j=i;
end
save('problem3_1_1.mat');


function [prod,greedySolve]=greedy2(cell)  %greedy2表示用于2道工序
%必须输入一个1×2元胞数组cell，cell{1,1}为第1类CNC（加工第1道工序）的1×n编号集合（数列），cell{1,2}为第2类CNC的编号集合
%输出prod为产量，greedySolve为贪婪法解出的RGV工作顺序
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
    0 0 23 23 41 41 59 59;
    0 0 23 23 41 41 59 59;
    23 23 0 0 23 23 41 41;
    23 23 0 0 23 23 41 41;
    41 41 23 23 0 0 23 23;
    41 41 23 23 0 0 23 23;
    59 59 41 41 23 23 0 0;
    59 59 41 41 23 23 0 0;
];
%reload(i)表示第i台CNC上料下料所需时间
global reload;
reload=[30 35 30 35 30 35 30 35];
global work;
work=[280 500];%CNC第一道工序要400秒，第二道工序378秒。

wash=zeros(1,8);
for i=1:s(2)
    wash(cell{1,2}(1,i))=30;%只有从第2类机器下料时需要花时间清洗
end

remain=zeros(1,8);%每台机器剩余加工时间

j=1;%当前所在CNC
remainTime=8*3600;%记录剩余时间
count=0;%RGV一共进行了count次上下料
prod=0;%记录产量（给2上料一次则产量+1）
nextCNCtype=1;%标记RGV下一次应找哪种CNC
damageCount=0;%一共发生过几次故障
damaged=[0 0 0 0 0 0 0 0];%记录每台CNC是否已故障
%判断下次可做哪道工序的规则：
%情况0：一开始应做第1道工序（显然）
%情况1：如果刚才给一个无载荷的1类CNC上下料，则上下料完成后RGV手里没有任何东西，因此应当继续找一个1类CNC
%情况2：如果刚才给一个有载荷的1类CNC上下料，则上下料完成后RGV手里有一个应该交给2类CNC的熟料
%情况3：如果刚才给一个2类CNC上下料，则上下料完成后CNC手里没有任何东西，应找一个1类CNC
%理论上RGV手里没有东西时，下一步既可以找1类CNC上下料，也可以继续给2类CNC下料，但是找2类CNC并不会节约任何时间。
CNCloaded=2*ones(1,8);%记录CNC是否被装过物料。3表示没装过，1表示这是第1类CNC且装过，2表示这是第2类CNC且装过。
while remainTime>0
    total=max(tm(j,:),remain)+reload+wash;%前往下一台CNC，装料，清洗所需总时间
    %下面求前往下一台类型正确的机器的耗时最小值，以及这台机器编号
    mi=total(cell{1,nextCNCtype}(1,1));
    i=cell{1,nextCNCtype}(1,1);
    for k=2:s(nextCNCtype)
        if(mi>total(cell{1,nextCNCtype}(1,k)))
            mi=total(cell{1,nextCNCtype}(1,k));
            i=cell{1,nextCNCtype}(1,k);
        end
    end
    %现在去第i台机器是最快的
    prod=prod+nextCNCtype-1;%如果下次去2类CNC，则产量+1
    tmp=CNCloaded(i);%记录第i台CNC原本的装载情况
    CNCloaded(i)=nextCNCtype;
    count=count+1;
    remainTime=remainTime-mi;%RGV工作时总时间减少
    remain=max(remain-mi,[0 0 0 0 0 0 0 0]);%没有被RGV光顾的CNC继续工作直到自己剩余时间为0
    %决定第i台机器要不要损坏
    ranDamage=rand(1);%随机决定第iGreedy台CNC在这次工作中是否会损坏
    if(ranDamage>0.99)
        workTime=unidrnd(work(nextCNCtype))-1;%正常工作的时间（工作了这么多时间后损坏），取值范围为闭区间[0,work(nextCNCtype)-1]（完成加工所需时间减1）
        repairTime=unidrnd(10*60+1)+10*60-1;%修复时间取值范围为闭区间[10分钟,20分钟]
        remain(i)=workTime+repairTime-wash(i);
        %在为第iGreedy台CNC装料完成后，RGV清洗时CNC也在工作，因此当RGV又可动时这台CNC已经运行了清洗所需的时间
        wash(i)=0;%下次为该CNC下料时不需要清洗
        damaged(i)=1;
        damageCount=damageCount+1;
        CNCloaded(i)=2;
        tmp=2;
        if(nextCNCtype==2)
            prod=prod-1;
        end
    else
        remain(i)=work(nextCNCtype)-wash(i);
        wash(i)=30;
        damaged(i)=0;
        CNCloaded(i)=nextCNCtype;
    end
    greedySolve(count)=i;
    j=i;
    nextCNCtype=3-tmp;
end
end
