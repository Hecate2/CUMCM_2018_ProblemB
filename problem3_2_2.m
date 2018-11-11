clear

%CNC�����k��j�б�ʾ��k������ĵ�j̨�����ɼӹ���һ������1��2��
%CNC������2^8=256�У����8̨CNC�ܼӹ��Ĺ�����������
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
%���е�1�У�����CNC��ֻ�ܼӹ���1���򣩺͵�256�У�����CNC��ֻ�ܼӹ���1������Ȼ�ǲ����ܲ��õġ����������������
%Ȼ������CNC1Ԫ�������CNC2Ԫ�����顣
%CNCcell�ĺ��壺�ڵ�k��CNC���ŷ����У���ӦCNC�����k�У������Լӹ���1����������л�����ŷ���CNCcell{k}{1}�С�
CNCcell=cell(256,2);
for i=1:1:256
    for j=1:1:8
        CNCcell{i,CNC(i,j)}(size(CNCcell{i,CNC(i,j)},2)+1)=j;
    end
end
prod=zeros(256,10);%��¼����������ÿ�λ�����������ģ����Լ�¼10��
%����������ÿһ��CNC�İ��ţ���̰���㷨��һ����
greedySolves=cell(256,1);%��Ȼ������256�У�����1�к����һ�лᱻ����
for i=2:1:255
%for i=173:1:255 %���ڴӵ�173�������ʼ������
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
%���濪ʼ��ѡ�е�CNC��������ģ������
out=zeros(420,6);
damage=zeros(100,4);

%CNC�𻵵�ԭ��
%ÿ̨CNCÿ��1�μӹ�����1%������
%��RGV������һ��ǰ����į�������������������������̨�����Ƿ�Ҫ�𻵣���������һ��ά��ʣ��ʱ��

%ģ���ִ�ȱ�ݣ���RGV��ǰ����įCNC�Ĺ����У���CNCͻȻ�𻵣���RGV����ô����
%����RGV�ƶ��ľ���������ʱ�䲻�����Թ�ϵ���������ģ��RGV�ڡ���·�ϡ��ı��ƶ�Ŀ�����������ĵ�ʱ��
%Ŀǰ�����ļ����ǣ����RGVǰ����įCNC�Ĺ����и�CNCͻȻ�𻵣���RGV�ܹ���ǰԤ֪��һ�𻵣���ǰ����CNC���Ա���RGV�ƶ���ʱ����֪�����

%���Ȳ��ԣ���̰����ʽ����RGV����RGV����ǰ��Ŀǰ���������CNC��RGV��ǰ����įCNCʱ����CNCͻȻ�𻵣���RGV������ǰԤ֪���𻵣��Ҳ�ǰ����CNC

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
remainTime=8*3600;
work=[280 500];%CNC��һ������Ҫ400�룬�ڶ�������378�롣
nextCNCtype=1;
CNCloaded=2*ones(1,8);

RGVcarrying=1;%RGV��Я���������ǵڼ���
code=0;%����һ������
loadedNumber=[0 0 0 0 0 0 0 0];%ÿ̨CNC�����еĹ����ǵڼ���

j=1;    %��RGV��ǰλ���ڵ�j̨CNC��һ��ʼRGV�ڵ�1̨CNCλ��
count=0;%RGVһ��������count��������
damageCount=0;%һ�����ֹ�������
remain=[0 0 0 0 0 0 0 0];%ÿ̨CNC���ж೤ʱ��׼������һ��������(������ɼӹ�������޸�)
damaged=[0 0 0 0 0 0 0 0];%CNC�Ƿ��ˡ�û����ȡ0�����˵Ŀ�ȡ��0��������
wash=zeros(1,8);
for i=1:s(2)
    wash(cell{1,2}(1,i))=30;%ֻ�дӵ�2���������ʱ��Ҫ��ʱ����ϴ
end
loadedNumber=[0 0 0 0 0 0 0 0];
timer=0;

while remainTime>0
    count=count+1;
    total=max(tm(j,:),remain)+reload+wash;%ǰ����һ̨CNC��װ�ϣ���ϴ������ʱ��
    %������ǰ����һ̨������ȷ�Ļ����ĺ�ʱ��Сֵ���Լ���̨�������
    mi=total(cell{1,nextCNCtype}(1,1));
    i=cell{1,nextCNCtype}(1,1);
    for k=2:s(nextCNCtype)
        if(mi>total(cell{1,nextCNCtype}(1,k)))
            mi=total(cell{1,nextCNCtype}(1,k));
            i=cell{1,nextCNCtype}(1,k);
        end
    end
    %����ȥ��į����������
    %������ǰ������һ̨���������Ƿ���ȷ
    if(CNC(1,i)~=nextCNCtype)
        prod=0;
        return
    end
    
    if(nextCNCtype==1)
        code=code+1;
        RGVcarrying=code;
    end
    
    timer=timer+max(tm(j,i),remain(i));

    %��¼������
    out(RGVcarrying,nextCNCtype*3-2)=i;
    out(RGVcarrying,nextCNCtype*3-1)=timer;
    if(loadedNumber(i)~=0)
        out(loadedNumber(i),nextCNCtype*3)=timer;
    end
    
    %CNC��װ������RGV��װ���ｻ��
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
    ranDamage=rand(1);%���������įCNC����ι������Ƿ����
    if(ranDamage>0.99)
        workTime=unidrnd(work(nextCNCtype))-1;%����������ʱ�䣨��������ô��ʱ����𻵣���ȡֵ��ΧΪ������[0,work-1]����ɼӹ�����ʱ���1��
        repairTime=unidrnd(10*60+1)+10*60-1;%�޸�ʱ��ȡֵ��ΧΪ������[10����,20����]
        remain(i)=workTime+repairTime-wash(i);
        %��Ϊ��įCNCװ����ɺ�RGV��ϴʱCNCҲ�ڹ�������˵�RGV�ֿɶ�ʱ��̨CNC�Ѿ���������ϴ�����ʱ��
        wash(i)=0;%�´�Ϊ��CNC����ʱ����Ҫ��ϴ
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
    %total(i);Ϊ���RGV�ƶ������ϣ���ϴ����ʱ��
    prod=prod+nextCNCtype-1;%����´�ȥ2��CNC�������+1
    CNCloaded(i)=nextCNCtype;
    
    remainTime=remainTime-total(i);%RGV����ʱ��ʱ�����
    remain=max(remain-total(i),[0 0 0 0 0 0 0 0]);%û�б�RGV��˵�CNC��������ֱ���Լ�ʣ��ʱ��Ϊ0
    remain(i)=work(nextCNCtype)-wash(i);%��װ�ϵ�CNC��ʼ��һ�ι�������������ϴʱ��װ�ϵ�CNCҲ�ڹ�������˵�RGV�ֿɶ�ʱ��̨CNC�Ѿ���������ϴ�����ʱ��
    nextCNCtype=3-tmp;
    j=i;
end
save('problem3_1_1.mat');


function [prod,greedySolve]=greedy2(cell)  %greedy2��ʾ����2������
%��������һ��1��2Ԫ������cell��cell{1,1}Ϊ��1��CNC���ӹ���1�����򣩵�1��n��ż��ϣ����У���cell{1,2}Ϊ��2��CNC�ı�ż���
%���prodΪ������greedySolveΪ̰���������RGV����˳��
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
global reload;
reload=[30 35 30 35 30 35 30 35];
global work;
work=[280 500];%CNC��һ������Ҫ400�룬�ڶ�������378�롣

wash=zeros(1,8);
for i=1:s(2)
    wash(cell{1,2}(1,i))=30;%ֻ�дӵ�2���������ʱ��Ҫ��ʱ����ϴ
end

remain=zeros(1,8);%ÿ̨����ʣ��ӹ�ʱ��

j=1;%��ǰ����CNC
remainTime=8*3600;%��¼ʣ��ʱ��
count=0;%RGVһ��������count��������
prod=0;%��¼��������2����һ�������+1��
nextCNCtype=1;%���RGV��һ��Ӧ������CNC
damageCount=0;%һ�����������ι���
damaged=[0 0 0 0 0 0 0 0];%��¼ÿ̨CNC�Ƿ��ѹ���
%�ж��´ο����ĵ�����Ĺ���
%���0��һ��ʼӦ����1��������Ȼ��
%���1������ղŸ�һ�����غɵ�1��CNC�����ϣ�����������ɺ�RGV����û���κζ��������Ӧ��������һ��1��CNC
%���2������ղŸ�һ�����غɵ�1��CNC�����ϣ�����������ɺ�RGV������һ��Ӧ�ý���2��CNC������
%���3������ղŸ�һ��2��CNC�����ϣ�����������ɺ�CNC����û���κζ�����Ӧ��һ��1��CNC
%������RGV����û�ж���ʱ����һ���ȿ�����1��CNC�����ϣ�Ҳ���Լ�����2��CNC���ϣ�������2��CNC�������Լ�κ�ʱ�䡣
CNCloaded=2*ones(1,8);%��¼CNC�Ƿ�װ�����ϡ�3��ʾûװ����1��ʾ���ǵ�1��CNC��װ����2��ʾ���ǵ�2��CNC��װ����
while remainTime>0
    total=max(tm(j,:),remain)+reload+wash;%ǰ����һ̨CNC��װ�ϣ���ϴ������ʱ��
    %������ǰ����һ̨������ȷ�Ļ����ĺ�ʱ��Сֵ���Լ���̨�������
    mi=total(cell{1,nextCNCtype}(1,1));
    i=cell{1,nextCNCtype}(1,1);
    for k=2:s(nextCNCtype)
        if(mi>total(cell{1,nextCNCtype}(1,k)))
            mi=total(cell{1,nextCNCtype}(1,k));
            i=cell{1,nextCNCtype}(1,k);
        end
    end
    %����ȥ��į����������
    prod=prod+nextCNCtype-1;%����´�ȥ2��CNC�������+1
    tmp=CNCloaded(i);%��¼��įCNCԭ����װ�����
    CNCloaded(i)=nextCNCtype;
    count=count+1;
    remainTime=remainTime-mi;%RGV����ʱ��ʱ�����
    remain=max(remain-mi,[0 0 0 0 0 0 0 0]);%û�б�RGV��˵�CNC��������ֱ���Լ�ʣ��ʱ��Ϊ0
    %������į����Ҫ��Ҫ��
    ranDamage=rand(1);%���������iGreedy̨CNC����ι������Ƿ����
    if(ranDamage>0.99)
        workTime=unidrnd(work(nextCNCtype))-1;%����������ʱ�䣨��������ô��ʱ����𻵣���ȡֵ��ΧΪ������[0,work(nextCNCtype)-1]����ɼӹ�����ʱ���1��
        repairTime=unidrnd(10*60+1)+10*60-1;%�޸�ʱ��ȡֵ��ΧΪ������[10����,20����]
        remain(i)=workTime+repairTime-wash(i);
        %��Ϊ��iGreedy̨CNCװ����ɺ�RGV��ϴʱCNCҲ�ڹ�������˵�RGV�ֿɶ�ʱ��̨CNC�Ѿ���������ϴ�����ʱ��
        wash(i)=0;%�´�Ϊ��CNC����ʱ����Ҫ��ϴ
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
