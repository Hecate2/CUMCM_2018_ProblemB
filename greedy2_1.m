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
prod=zeros(256,1);%��¼����
%����������ÿһ��CNC�İ��ţ���̰���㷨��һ����
greedySolves=cell(256,1);%��Ȼ������256�У�����1�к����һ�лᱻ����
for i=2:1:255
%for i=173:1:255 %���ڴӵ�173�������ʼ������
    [prod(i,1),greedySolves{i,1}]=greedy2({CNCcell{i,1},CNCcell{i,2}});
end

save('greedy2_1.mat','CNC','CNCcell','greedySolves','prod');
plot(prod);
xlim([1 256]);

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
    0 0 20 20 33 33 46 46;
    0 0 20 20 33 33 46 46;
    20 20 0 0 20 20 33 33;
    20 20 0 0 20 20 33 33;
    33 33 20 20 0 0 20 20;
    33 33 20 20 0 0 20 20;
    46 46 33 33 20 20 0 0;
    46 46 33 33 20 20 0 0;
];
%reload(i)��ʾ��įCNC������������ʱ��
global reload;
reload=[28 31 28 31 28 31 28 31];
global work;
work=[400 378];%CNC��һ������Ҫ400�룬�ڶ�������378�롣

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
    remain(i)=work(nextCNCtype)-wash(i);%��װ�ϵ�CNC��ʼ��һ�ι�������������ϴʱ��װ�ϵ�CNCҲ�ڹ�������˵�RGV�ֿɶ�ʱ��̨CNC�Ѿ���������ϴ�����ʱ��
    greedySolve(count)=i;
    j=i;
    nextCNCtype=3-tmp;
end
end
