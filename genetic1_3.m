clear
%�Ŵ��㷨
%��4�����ÿ������380������DNA����CNCѡ��˳��
%Ҫ�ж�������������ĺû���ֻҪ��ǰ���ٸ�����������8Сʱ����8Сʱ�������ٶ���

%total���б�ʾRGV������ͣ����CNC�����������һ��ǰ����įCNCΪ��װ�ϣ���total(i)ʱ���RGV�����ٴ��ж�
%������RGV�ƶ�ʱ�䣬CNC����ʱ������Ϻ���ϴʱ�䣩
%total=tm(1,:)+reload;%���ǳ�ʼ״̬
%����RGV���ӵ�j̨CNC��������total�Ĺ�ʽΪ:
%total=max(tm(j,:),remain)+reload+wash;
%�ƶ�ʱ��ͻ���ʣ�๤��ʱ������ֵ������������ʱ�����ϴʱ��
j=1;    %��RGV��ǰλ���ڵ�j̨CNC��һ��ʼRGV�ڵ�1̨CNCλ��

count=0;%RGVһ��������count��������
%����RGV��һ��ǰ����įCNC

%���㵽��ÿ��CNC��Ϊ��װ�ϣ���ϴ��������ʱ��
% total=max(tm(j,:),remain)+reload+wash;
% remainTime=remainTime-mi;
% remain=max(remain-mi,[0 0 0 0 0 0 0 0]);%û�б�װ�ϵ�CNC��������ֱ���Լ�ʣ��ʱ��Ϊ0
% remain(i)=work-wash(i);%��װ�ϵ�CNC��ʼ��һ�ι�������������ϴʱ��װ�ϵ�CNCҲ�ڹ�������˵�RGV�ֿɶ�ʱ��̨CNC�Ѿ���������ϴ�����ʱ��
% wash(i)=25;
% result(count)=i;

%����7�������DNA��
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
        prod(i)=checkProduction(life(i,:));  %prod��Ϊproduct
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
    life(midIndex1,:)=nextGen([life(maIndex,:);life(midIndex1,:)]);%�������ӽ�
    life(midIndex2,:)=ceil(rand(1,len)*8);%�������
end

for i=1:s
    prod(i)=checkProduction(life(i,:));  %prod��Ϊproduct
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
reload=[28 31 28 31 28 31 28 31];
global work;
work=545;%CNC����һ������Ҫ545�롣

    j=1;%��ǰ����CNC
    production=0;%Ŀǰ�Ѹ�CNC���ϵ��ۼƴ���
    remainTime=8*3600;
    %remain���б�ʾ��įCNC����Ҫremain(i)ʱ����ɹ���
    remain=[0 0 0 0 0 0 0 0];
    %wash��ʾ�����Ϻ�������ϴ���ĵ�ʱ��
    %һ��ʼ����CNC�����أ���������Ϻ�������ϴ����į����������Ϻ�wash(DNA(production))Ӧ��Ϊ25
    wash=[0 0 0 0 0 0 0 0];
    while remainTime>=0
        production=production+1;
        total=max(tm(j,:),remain)+reload+wash;
        %DNA(production)Ϊ��һ��Ҫ���ϵ�CNC;%total(DNA(production))Ϊ����ƶ�����������ʱ��
        remainTime=remainTime-total(DNA(production));
        remain=max(remain-total(DNA(production)),[0 0 0 0 0 0 0 0]);%û�б�װ�ϵ�CNC��������ֱ���Լ�ʣ��ʱ��Ϊ0
        remain(DNA(production))=work-wash(DNA(production));%��װ�ϵ�CNC��ʼ��һ�ι�������������ϴʱ��װ�ϵ�CNCҲ�ڹ�������˵�RGV�ֿɶ�ʱ��̨CNC�Ѿ���������ϴ�����ʱ��
        wash(DNA(production))=25;
        j=DNA(production);
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
