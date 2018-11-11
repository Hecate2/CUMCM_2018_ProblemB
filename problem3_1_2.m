clear

out=zeros(420,3);
damage=zeros(100,4);

%CNC损坏的原则：
%每台CNC每做1次加工就有1%概率损坏
%若RGV决定下一次前往第i台机器，则立即用随机数决定这台机器是否要损坏，并赋予它一个维修剩余时间

%模型现存缺陷：若RGV在前往第i台CNC的过程中，该CNC突然损坏，则RGV该怎么做？
%由于RGV移动的距离与所花时间不是线性关系，因此难以模拟RGV在“半路上”改变移动目标所额外消耗的时间
%目前做出的假设是：如果RGV前往第i台CNC的过程中该CNC突然损坏，则RGV能够提前预知这一损坏，不前往该CNC，以避免RGV移动耗时不可知的情况

%调度策略：按贪婪方式调度RGV，但RGV不会前往目前正在修理的CNC。RGV在前往第i台CNC时若该CNC突然损坏，则RGV可以提前预知该损坏，且不前往该CNC

remainTime=8*3600;
j=1;    %设RGV当前位置在第j台CNC。一开始RGV在第1台CNC位置
count=0;%RGV一共进行了count次上下料
damageCount=0;%一共出现过几次损坏
remain=[0 0 0 0 0 0 0 0];%每台CNC还有多长时间准备好下一次上下料(包括完成加工和完成修复)
damaged=[0 0 0 0 0 0 0 0];%CNC是否坏了。没坏的取0，坏了的可取非0的任意数
wash=[0 0 0 0 0 0 0 0];
loadedNumber=[0 0 0 0 0 0 0 0];
timer=0;
while remainTime>0
    count=count+1;
    %[j,remain,wash,remainTime,damaged,damageCount]=greedy(j,remain,wash,remainTime,damaged,damageCount);
    %输入RGV当前所在CNC的编号，每台CNC接受下一次上下料的剩余时间，以及清洗时间
    %输出RGV按贪婪法决定下一次去的CNC的编号i，以及为每个CNC装料直到下一次能够行动所消耗的时间
    work=580;%CNC处理一个物料要560秒。
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
    
    %假设RGV下一步前往第i台CNC
    %用贪婪算法找出i
    %计算到达每个CNC，为其装料，清洗物料所需时间
    total=max(tm(j,:),remain.*(damaged+ones(1,8)))+reload+wash;
    %remain.*(damaged+ones(1,8))扩大了RGV眼中已损坏CNC的修复剩余时间，阻止RGV前往损坏的CNC
    %RGV并不能预知修复剩余时间，所以不能因为某CNC“还有5秒修好”就前往该CNC
    %RGV寻找本次耗时最短的未损坏CNC为其装料
    [mi,i]=min(total);%mi为minimum，i在这里为最小值的下标
    
    timer=timer+max(tm(j,i),remain(i));
    
    %记录上料下料
    if (loadedNumber(i)~=0)%CNC上已有的工件被下料
        out(loadedNumber(i),3)=timer;
    end
    out(count,1)=i;%第count件新工件上料
    out(count,2)=timer;
    loadedNumber(i)=count;
    timer=timer+reload(i)+wash(i);    %上料，清洗

    remainTime=remainTime-mi;
    remain=max(remain-mi,[0 0 0 0 0 0 0 0]);%没有被RGV光顾的CNC继续工作/被修复直到自己剩余时间为0
    damaged=damaged.*remain./(remain+ones(1,8));%remain为0时损坏机器肯定已经修好了，因此damaged设为0。remain不为0时damaged通过这一语句保持不为0
    
    ranDamage=rand(1);%随机决定第i台CNC在这次工作中是否会损坏
    if(ranDamage>0.99)
        workTime=unidrnd(work)-1;%正常工作的时间（工作了这么多时间后损坏），取值范围为闭区间[0,work-1]（完成加工所需时间减1）
        repairTime=unidrnd(10*60+1)+10*60-1;%修复时间取值范围为闭区间[10分钟,20分钟]
        remain(i)=workTime+repairTime-wash(i);
        %在为第i台CNC装料完成后，RGV清洗时CNC也在工作，因此当RGV又可动时这台CNC已经运行了清洗所需的时间
        wash(i)=0;%下次为该CNC下料时不需要清洗
        damaged(i)=1;
        damageCount=damageCount+1;
        damage(damageCount,1)=loadedNumber(i);
        loadedNumber(i)=0;
        damage(damageCount,2)=i;
        damage(damageCount,3)=timer+workTime-wash(i);
        damage(damageCount,4)=timer+workTime+repairTime-wash(i);
    else
        remain(i)=work-wash(i);
        wash(i)=30;
        damaged(i)=0;
    end
j=i;
i=j;
end
prod=count-damageCount
save('problem3_1_1.mat');

function [i,remain,wash,remainTime,damaged,damageCount]=greedy(j,remain,wash,remainTime,damaged,damageCount)
%输入RGV当前所在CNC的编号，每台CNC接受下一次上下料的剩余时间，以及清洗时间
%输出RGV按贪婪法决定下一次去的CNC的编号i，以及为每个CNC装料直到下一次能够行动所消耗的时间
work=580;%CNC处理一个物料要560秒。
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

%假设RGV下一步前往第i台CNC
%用贪婪算法找出i
%计算到达每个CNC，为其装料，清洗物料所需时间
total=max(tm(j,:),remain.*(damaged+ones(1,8)))+reload+wash;
%remain.*(damaged+ones(1,8))扩大了RGV眼中已损坏CNC的修复剩余时间，阻止RGV前往损坏的CNC
%RGV并不能预知修复剩余时间，所以不能因为某CNC“还有5秒修好”就前往该CNC
%RGV寻找本次耗时最短的未损坏CNC为其装料
[mi,i]=min(total);%mi为minimum，i在这里为最小值的下标
remainTime=remainTime-mi;
remain=max(remain-mi,[0 0 0 0 0 0 0 0]);%没有被RGV光顾的CNC继续工作/被修复直到自己剩余时间为0
damaged=damaged.*remain./(remain+ones(1,8));%remain为0时损坏机器肯定已经修好了，因此damaged设为0。remain不为0时damaged通过这一语句保持不为0

ranDamage=rand(1);%随机决定第i台CNC在这次工作中是否会损坏
if(ranDamage>0.99)
    workTime=unidrnd(work)-1;%正常工作的时间（工作了这么多时间后损坏），取值范围为闭区间[0,work-1]（完成加工所需时间减1）
    repairTime=unidrnd(10*60+1)+10*60-1;%修复时间取值范围为闭区间[10分钟,20分钟]
    remain(i)=workTime+repairTime-wash(i);
    %在为第i台CNC装料完成后，RGV清洗时CNC也在工作，因此当RGV又可动时这台CNC已经运行了清洗所需的时间
    wash(i)=0;%下次为该CNC下料时不需要清洗
    damaged(i)=1;
    damageCount=damageCount+1;
else
    remain(i)=work-wash(i);
    wash(i)=30;
    damaged(i)=0;
end
end
