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
prod=zeros(256,1);%记录产量
%接下来对于每一种CNC的安排，用贪婪算法求一个解
greedySolves=cell(256,1);%虽然安排了256行，但第1行和最后一行会被无视
for i=2:1:255
%for i=173:1:255 %用于从第173种情况开始做测试
    [prod(i,1),greedySolves{i,1}]=greedy2({CNCcell{i,1},CNCcell{i,2}});
end

save('greedy2_1.mat','CNC','CNCcell','greedySolves','prod');
plot(prod);
xlim([1 256]);

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
global reload;
reload=[28 31 28 31 28 31 28 31];
global work;
work=[400 378];%CNC第一道工序要400秒，第二道工序378秒。

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
    remain(i)=work(nextCNCtype)-wash(i);%被装料的CNC开始新一次工作。在物料清洗时被装料的CNC也在工作，因此当RGV又可动时这台CNC已经运行了清洗所需的时间
    greedySolve(count)=i;
    j=i;
    nextCNCtype=3-tmp;
end
end
