clear

out=zeros(420,3);
damage=zeros(100,4);

%CNC�𻵵�ԭ��
%ÿ̨CNCÿ��1�μӹ�����1%������
%��RGV������һ��ǰ����į�������������������������̨�����Ƿ�Ҫ�𻵣���������һ��ά��ʣ��ʱ��

%ģ���ִ�ȱ�ݣ���RGV��ǰ����įCNC�Ĺ����У���CNCͻȻ�𻵣���RGV����ô����
%����RGV�ƶ��ľ���������ʱ�䲻�����Թ�ϵ���������ģ��RGV�ڡ���·�ϡ��ı��ƶ�Ŀ�����������ĵ�ʱ��
%Ŀǰ�����ļ����ǣ����RGVǰ����įCNC�Ĺ����и�CNCͻȻ�𻵣���RGV�ܹ���ǰԤ֪��һ�𻵣���ǰ����CNC���Ա���RGV�ƶ���ʱ����֪�����

%���Ȳ��ԣ���̰����ʽ����RGV����RGV����ǰ��Ŀǰ���������CNC��RGV��ǰ����įCNCʱ����CNCͻȻ�𻵣���RGV������ǰԤ֪���𻵣��Ҳ�ǰ����CNC

remainTime=8*3600;
j=1;    %��RGV��ǰλ���ڵ�j̨CNC��һ��ʼRGV�ڵ�1̨CNCλ��
count=0;%RGVһ��������count��������
damageCount=0;%һ�����ֹ�������
remain=[0 0 0 0 0 0 0 0];%ÿ̨CNC���ж೤ʱ��׼������һ��������(������ɼӹ�������޸�)
damaged=[0 0 0 0 0 0 0 0];%CNC�Ƿ��ˡ�û����ȡ0�����˵Ŀ�ȡ��0��������
wash=[0 0 0 0 0 0 0 0];
loadedNumber=[0 0 0 0 0 0 0 0];
timer=0;
while remainTime>0
    count=count+1;
    %[j,remain,wash,remainTime,damaged,damageCount]=greedy(j,remain,wash,remainTime,damaged,damageCount);
    %����RGV��ǰ����CNC�ı�ţ�ÿ̨CNC������һ�������ϵ�ʣ��ʱ�䣬�Լ���ϴʱ��
    %���RGV��̰����������һ��ȥ��CNC�ı��i���Լ�Ϊÿ��CNCװ��ֱ����һ���ܹ��ж������ĵ�ʱ��
    work=580;%CNC����һ������Ҫ560�롣
    %tm�����ʾRGV����̨CNC֮���ƶ������ʱ��(time for movement)
    %����tm(1,3)��ʾRGV��1��CNC�ƶ���3��CNC�����ʱ�䣬�ھ�����Ϊ��1�е�3�е�ֵ
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
    
    %reload(i)��ʾ��įCNC������������ʱ��
    reload=[30 35 30 35 30 35 30 35];
    
    %����RGV��һ��ǰ����įCNC
    %��̰���㷨�ҳ�i
    %���㵽��ÿ��CNC��Ϊ��װ�ϣ���ϴ��������ʱ��
    total=max(tm(j,:),remain.*(damaged+ones(1,8)))+reload+wash;
    %remain.*(damaged+ones(1,8))������RGV��������CNC���޸�ʣ��ʱ�䣬��ֹRGVǰ���𻵵�CNC
    %RGV������Ԥ֪�޸�ʣ��ʱ�䣬���Բ�����ΪĳCNC������5���޺á���ǰ����CNC
    %RGVѰ�ұ��κ�ʱ��̵�δ��CNCΪ��װ��
    [mi,i]=min(total);%miΪminimum��i������Ϊ��Сֵ���±�
    
    timer=timer+max(tm(j,i),remain(i));
    
    %��¼��������
    if (loadedNumber(i)~=0)%CNC�����еĹ���������
        out(loadedNumber(i),3)=timer;
    end
    out(count,1)=i;%��count���¹�������
    out(count,2)=timer;
    loadedNumber(i)=count;
    timer=timer+reload(i)+wash(i);    %���ϣ���ϴ

    remainTime=remainTime-mi;
    remain=max(remain-mi,[0 0 0 0 0 0 0 0]);%û�б�RGV��˵�CNC��������/���޸�ֱ���Լ�ʣ��ʱ��Ϊ0
    damaged=damaged.*remain./(remain+ones(1,8));%remainΪ0ʱ�𻵻����϶��Ѿ��޺��ˣ����damaged��Ϊ0��remain��Ϊ0ʱdamagedͨ����һ��䱣�ֲ�Ϊ0
    
    ranDamage=rand(1);%���������įCNC����ι������Ƿ����
    if(ranDamage>0.99)
        workTime=unidrnd(work)-1;%����������ʱ�䣨��������ô��ʱ����𻵣���ȡֵ��ΧΪ������[0,work-1]����ɼӹ�����ʱ���1��
        repairTime=unidrnd(10*60+1)+10*60-1;%�޸�ʱ��ȡֵ��ΧΪ������[10����,20����]
        remain(i)=workTime+repairTime-wash(i);
        %��Ϊ��įCNCװ����ɺ�RGV��ϴʱCNCҲ�ڹ�������˵�RGV�ֿɶ�ʱ��̨CNC�Ѿ���������ϴ�����ʱ��
        wash(i)=0;%�´�Ϊ��CNC����ʱ����Ҫ��ϴ
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
%����RGV��ǰ����CNC�ı�ţ�ÿ̨CNC������һ�������ϵ�ʣ��ʱ�䣬�Լ���ϴʱ��
%���RGV��̰����������һ��ȥ��CNC�ı��i���Լ�Ϊÿ��CNCװ��ֱ����һ���ܹ��ж������ĵ�ʱ��
work=580;%CNC����һ������Ҫ560�롣
%tm�����ʾRGV����̨CNC֮���ƶ������ʱ��(time for movement)
%����tm(1,3)��ʾRGV��1��CNC�ƶ���3��CNC�����ʱ�䣬�ھ�����Ϊ��1�е�3�е�ֵ
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

%reload(i)��ʾ��įCNC������������ʱ��
reload=[30 35 30 35 30 35 30 35];

%����RGV��һ��ǰ����įCNC
%��̰���㷨�ҳ�i
%���㵽��ÿ��CNC��Ϊ��װ�ϣ���ϴ��������ʱ��
total=max(tm(j,:),remain.*(damaged+ones(1,8)))+reload+wash;
%remain.*(damaged+ones(1,8))������RGV��������CNC���޸�ʣ��ʱ�䣬��ֹRGVǰ���𻵵�CNC
%RGV������Ԥ֪�޸�ʣ��ʱ�䣬���Բ�����ΪĳCNC������5���޺á���ǰ����CNC
%RGVѰ�ұ��κ�ʱ��̵�δ��CNCΪ��װ��
[mi,i]=min(total);%miΪminimum��i������Ϊ��Сֵ���±�
remainTime=remainTime-mi;
remain=max(remain-mi,[0 0 0 0 0 0 0 0]);%û�б�RGV��˵�CNC��������/���޸�ֱ���Լ�ʣ��ʱ��Ϊ0
damaged=damaged.*remain./(remain+ones(1,8));%remainΪ0ʱ�𻵻����϶��Ѿ��޺��ˣ����damaged��Ϊ0��remain��Ϊ0ʱdamagedͨ����һ��䱣�ֲ�Ϊ0

ranDamage=rand(1);%���������įCNC����ι������Ƿ����
if(ranDamage>0.99)
    workTime=unidrnd(work)-1;%����������ʱ�䣨��������ô��ʱ����𻵣���ȡֵ��ΧΪ������[0,work-1]����ɼӹ�����ʱ���1��
    repairTime=unidrnd(10*60+1)+10*60-1;%�޸�ʱ��ȡֵ��ΧΪ������[10����,20����]
    remain(i)=workTime+repairTime-wash(i);
    %��Ϊ��įCNCװ����ɺ�RGV��ϴʱCNCҲ�ڹ�������˵�RGV�ֿɶ�ʱ��̨CNC�Ѿ���������ϴ�����ʱ��
    wash(i)=0;%�´�Ϊ��CNC����ʱ����Ҫ��ϴ
    damaged(i)=1;
    damageCount=damageCount+1;
else
    remain(i)=work-wash(i);
    wash(i)=30;
    damaged(i)=0;
end
end
