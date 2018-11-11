clear

load genetic2_1.mat
result=greedySolves{current,1};
cell={CNCcell{current,:}};
CNC=CNC(current,:);

out=zeros(size(result,2),6);%�����excel��ľ��󡣵�1��ΪCNC��ţ���2��Ϊ��CNC������ʱ�䣬��3��Ϊ��CNC������ʱ��

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
reload=[28 31 28 31 28 31 28 31];
work=[400 378];%CNC��һ������Ҫ400�룬�ڶ�������378�롣

wash=zeros(1,8);
for i=1:s(2)
    wash(cell{1,2}(1,i))=25;%ֻ�дӵ�2���������ʱ��Ҫ��ʱ����ϴ
end

remain=zeros(1,8);%ÿ̨����ʣ��ӹ�ʱ��

RGVcarrying=1;%RGV��Я���������ǵڼ���
code=0;%����һ������
loadedNumber=[0 0 0 0 0 0 0 0];%ÿ̨CNC�����еĹ����ǵڼ���

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
timer=0;
while remainTime>0
    count=count+1;
    total=max(tm(j,:),remain)+reload+wash;%ǰ����һ̨CNC��װ�ϣ���ϴ������ʱ��
    %������ǰ������һ̨���������Ƿ���ȷ
    if(CNC(1,result(1,count))~=nextCNCtype)
        prod=0;
        return
    end
    
    if(nextCNCtype==1)
        code=code+1;
        RGVcarrying=code;
    end
    
    timer=timer+max(tm(j,result(1,count)),remain(result(1,count)));

    %��¼������
    out(RGVcarrying,nextCNCtype*3-2)=result(1,count);
    out(RGVcarrying,nextCNCtype*3-1)=timer;
    if(loadedNumber(result(1,count))~=0)
        out(loadedNumber(result(1,count)),nextCNCtype*3)=timer;
    end
    
    %CNC��װ������RGV��װ���ｻ��
    tmpRGV=loadedNumber(result(1,count));
    loadedNumber(result(1,count))=RGVcarrying;
    if(nextCNCtype==1)
        RGVcarrying=tmpRGV;
    else
        RGVcarrying=0;
    end

    timer=timer+reload(result(1,count))+wash(result(1,count));

    tmp=CNCloaded(result(1,count));
    %total(result(1,count));Ϊ���RGV�ƶ������ϣ���ϴ����ʱ��
    prod=prod+nextCNCtype-1;%����´�ȥ2��CNC�������+1
    CNCloaded(result(1,count))=nextCNCtype;
    
    remainTime=remainTime-total(result(1,count));%RGV����ʱ��ʱ�����
    remain=max(remain-total(result(1,count)),[0 0 0 0 0 0 0 0]);%û�б�RGV��˵�CNC��������ֱ���Լ�ʣ��ʱ��Ϊ0
    remain(result(1,count))=work(nextCNCtype)-wash(result(1,count));%��װ�ϵ�CNC��ʼ��һ�ι�������������ϴʱ��װ�ϵ�CNCҲ�ڹ�������˵�RGV�ֿɶ�ʱ��̨CNC�Ѿ���������ϴ�����ʱ��
    j=result(1,count);
    nextCNCtype=3-tmp;
end

save('simulation2_1.mat');