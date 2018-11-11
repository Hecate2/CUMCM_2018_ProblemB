clear
load greedy2_3.mat;

ma=max(prod);
sLife=size(greedySolves,1);
lifeCount=sLife;

for i=1:1:sLife
    if(prod(i,1)/ma/0.9<1)%���ĳ����̰���㷨�Ĳ���������ǿ�����90%�����������Ϊ0����Ϊ��̭֮
        prod(i,1)=0;
        lifeCount=lifeCount-1;
    end
end

current=1;next=2;
%�������current����i����next����j�����ᱻMATLAB����������λ
elimThreshold=0;%����̰����������̭��ֵelimThreshold��̫������ֱ����̭
while lifeCount>5   %���while��ʱû���ô�
    %while current<=sLife-1
        if(prod(current,1)>elimThreshold*0.9) %����ֵ��90%���͵ģ�ֱ����̭
            next=current+1;
            while next<=sLife
                if(prod(next,1)>elimThreshold*0.9)
                    keep=1;
                    while(keep==1)
                        if(prod(next,1)<prod(current,1))
                            %�������j�Ĳ�������i�����j�������ᡣ
                            %���������j�Ĳ�����Ȼ����i����̭j
                            %���������j�Ĳ���������i�����ٸ�i�������ᡣ
                            %�κ�һ���������Բ��ܻ�ʤ����̭
                            elimThreshold=prod(next,1);%Ŀǰ�����ϵ��ߵĲ�������Ϊ��ֵ��
                            %���֮������̰��������elimThreshold��̫������ֱ����̭������
                            greedySolves{next,1}=evolve(CNC(next,:),{CNCcell{next,:}},greedySolves{next,1});
                            if(checkProduction(CNC(next,:),{CNCcell{next,:}},greedySolves{next,1})<=prod(current,1))
                                prod(next,1)=0;
                                lifeCount=lifeCount-1;
                                next=next+1;
                                keep=0;
                            end
                        else
                            elimThreshold=prod(current,1);%���֮������̰��������elimThreshold��̫������ֱ����̭������
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
%CNC������̨�����ܼӹ��ĵ������������
%cell��������һ��1��2Ԫ������cell��cell{1,1}Ϊ��1��CNC���ӹ���1�����򣩵�1��n��ż��ϣ����У���cell{1,2}Ϊ��2��CNC�ı�ż���
%DNA����RGVѡ��CNC��˳��
%���prodΪ����
s=[size(cell{1,1},2),size(cell{1,2},2)];
%ÿ��Ԫ�������еĴ�С����������0
% if (s(1)==0 || s(2)==0)
%     greedySolve=zeros(1,8);
%     return;
% end
%tm�����ʾRGV����̨CNC֮���ƶ������ʱ��(time for movement)
%����tm(1,3)��ʾRGV��1��CNC�ƶ���3��CNC�����ʱ�䣬�ھ�����Ϊ��1�е�3�е�ֵ
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
%reload(i)��ʾ��įCNC������������ʱ��
global reload;
reload=[27 32 27 32 27 32 27 32];
global work;
work=[455 182];%CNC��һ������Ҫ400�룬�ڶ�������378�롣

wash=zeros(1,8);
for i=1:s(2)
    wash(cell{1,2}(1,i))=25;%ֻ�дӵ�2���������ʱ��Ҫ��ʱ����ϴ
end

remain=zeros(1,8);%ÿ̨����ʣ��ӹ�ʱ��

j=1;%��ǰ����CNC
remainTime=8*3600;%��¼ʣ��ʱ��
count=0;%RGVһ��������count��������
prod=0;%��¼��������2����һ�������+1��
nextCNCtype=1;%���RGV��һ��Ӧ������CNC
%�ж��´ο����ĵ�����Ĺ���
%���0��һ��ʼӦ����1��������Ȼ��
%���1������ղŸ�һ�����غɵ�1��CNC�����ϣ�����������ɺ�RGV����û���κζ��������Ӧ��������һ��1��CNC
%���2������ղŸ�һ�����غɵ�1��CNC�����ϣ�����������ɺ�RGV������һ��Ӧ�ý���2��CNC������
%���3������ղŸ�һ��2��CNC�����ϣ�����������ɺ�CNC����û���κζ�����Ӧ��һ��1��CNC
%������RGV����û�ж���ʱ����һ���ȿ�����1��CNC�����ϣ�Ҳ���Լ�����2��CNC���ϣ�������2��CNC�������Լ�κ�ʱ�䡣
CNCloaded=2*ones(1,8);%��¼CNC��һ�α����Ϻ�RGV��װ�ź������ϡ�2��ʾС���ϲ��������ϡ�1��ʾС���ϻ��о�����1�����������
while remainTime>0
    count=count+1;
    total=max(tm(j,:),remain)+reload+wash;%ǰ����һ̨CNC��װ�ϣ���ϴ������ʱ��
    %������ǰ������һ̨���������Ƿ���ȷ�������ʱ
    if(CNC(1,DNA(1,count))~=nextCNCtype)
        prod=0;
        return
    end
    tmp=CNCloaded(DNA(1,count));
    %total(DNA(1,count));Ϊ���RGV�ƶ������ϣ���ϴ����ʱ��
    prod=prod+nextCNCtype-1;%����´�ȥ2��CNC�������+1
    CNCloaded(DNA(1,count))=nextCNCtype;
    remainTime=remainTime-total(DNA(1,count));%RGV����ʱ��ʱ�����
    remain=max(remain-total(DNA(1,count)),[0 0 0 0 0 0 0 0]);%û�б�RGV��˵�CNC��������ֱ���Լ�ʣ��ʱ��Ϊ0
    remain(DNA(1,count))=work(nextCNCtype)-wash(DNA(1,count));%��װ�ϵ�CNC��ʼ��һ�ι�������������ϴʱ��װ�ϵ�CNCҲ�ڹ�������˵�RGV�ֿɶ�ʱ��̨CNC�Ѿ���������ϴ�����ʱ��
    j=DNA(1,count);
    nextCNCtype=3-tmp;
end
end

function child=nextGen(parents)%����2��n�о���ÿ����һ����Ϊparent�����ÿ�������DNA��n��
    %parents=[chain1;chain2];
    s=size(parents,2);
    child=zeros(1,s);
    for i=1:s
        child(i)=parents(unidrnd(2),i);
    end
end

function evolution=changeDNA(life)%����һ�������1��n��DNA����ÿ��DNA��1%����ͻ��
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

function evolution=evolve(CNC,cell,DNA)  %��ָ����CNC���ŷ�ʽ��ͨ���Ŵ�����ʹ����RGVѡ��˳��(DNA)����
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
        prod(i)=checkProduction(CNC,cell,life(i,:));  %prod��Ϊproduct
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
    %����maIndex�����߲���������miIndex�����Ͳ�������������midIndex�����������������
    while(midIndex1==maIndex || midIndex1==miIndex)
        midIndex1=unidrnd(s);
    end
    while(midIndex2==maIndex || midIndex2==miIndex || midIndex2==midIndex1)
        midIndex2=unidrnd(s);
    end
    %�Ŵ�����
    life(miIndex,:)=changeDNA(life(maIndex,:));%�����������޸�Ϊ��߲��������ı���
    %life(midIndex1,:)=nextGen([life(maIndex,:);life(midIndex1,:)]);%�������ӽ�
    life(midIndex2,:)=ceil(rand(1,len)*8);%�������
end

for i=1:s
    prod(i)=checkProduction(CNC,cell,life(i,:));  %prod��Ϊproduct
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
