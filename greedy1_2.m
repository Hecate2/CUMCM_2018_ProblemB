clear

remainTime=8*3600;%总剩余时间（秒）

work=580;%CNC处理一个物料要580秒。

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

%remain数列表示第i台CNC还需要remain(i)时间完成工作
remain=[0 0 0 0 0 0 0 0];

%reload(i)表示第i台CNC上料下料所需时间
reload=[30 35 30 35 30 35 30 35];

%wash表示上下料后物料清洗消耗的时间
%一开始所有CNC都空载，因此上下料后无需清洗。第i台机器完成上料后，wash(i)应变为30
wash=[0 0 0 0 0 0 0 0];

%total数列表示RGV从现在停泊的CNC出发，如果下一步前往第i台CNC为其装料，则total(i)时间后RGV才能再次行动
%（包括RGV移动时间，CNC工作时间和下料后清洗时间）
%total=tm(1,:)+reload;%这是初始状态
%假设RGV正从第j台CNC出发，则total的公式为:
%total=max(tm(j,:),remain)+reload+wash;
%移动时间和机器剩余工作时间的最大值，加上上下料时间和清洗时间
j=1;    %设RGV当前位置在第j台CNC。一开始RGV在第1台CNC位置

count=0;%RGV一共进行了count次上下料
%假设RGV下一步前往第i台CNC

%先用贪婪算法找出一个解
while remainTime>0
    %计算到达每个CNC，为其装料，清洗物料所需时间
    total=max(tm(j,:),remain)+reload+wash;
    %RGV寻找本次耗时最短的CNC为其装料
    [mi,i]=min(total);%mi为minimum，i在这里为最小值的下标
    
    count=count+1;
    remainTime=remainTime-mi;
    remain=max(remain-mi,[0 0 0 0 0 0 0 0]);%没有被RGV光顾的CNC继续工作直到自己剩余时间为0
    remain(i)=work-wash(i);%被装料的CNC开始新一次工作。在物料清洗时被装料的CNC也在工作，因此当RGV又可动时这台CNC已经运行了清洗所需的时间
    wash(i)=30;
    result(count)=i;
    j=i;
end
save('greedy1_2.mat','result');
