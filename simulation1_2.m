clear

load genetic1_2.mat

out=zeros(size(result,2),3);%�����excel��ľ��󡣵�1��ΪCNC��ţ���2��Ϊ��CNC������ʱ�䣬��3��Ϊ��CNC������ʱ��

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
work=580;%CNC����һ������Ҫ560�롣

loadedNumber=[0 0 0 0 0 0 0 0];%ÿ̨CNC�����еĹ����ǵڼ���

j=1;%��ǰ����CNC
count=0;%Ŀǰ�Ѹ�CNC���ϵ��ۼƴ���
remainTime=8*3600;
%remain���б�ʾ��įCNC����Ҫremain(i)ʱ����ɹ���
remain=[0 0 0 0 0 0 0 0];
%wash��ʾ�����Ϻ�������ϴ���ĵ�ʱ��
%һ��ʼ����CNC�����أ���������Ϻ�������ϴ����į����������Ϻ�wash(result(count))Ӧ��Ϊ25
wash=[0 0 0 0 0 0 0 0];
timer=0;
while remainTime>0
    count=count+1;
    total=max(tm(j,:),remain)+reload+wash;
    %result(count)Ϊ��һ��Ҫ���ϵ�CNC;%total(result(count))Ϊ����ƶ�����������ʱ��
    remainTime=remainTime-total(result(count));
    timer=timer+max(tm(j,result(count)),remain(result(count)));    %�ƶ�
    if (loadedNumber(result(count))~=0)%CNC�����еĹ���������
        out(loadedNumber(result(count)),3)=timer;
    end
    out(count,1)=result(count);%��count���¹�������
    out(count,2)=timer;
    loadedNumber(result(count))=count;
    timer=timer+reload(result(count))+wash(result(count));    %���ϣ���ϴ
    remain=max(remain-total(result(count)),[0 0 0 0 0 0 0 0]);%û�б�װ�ϵ�CNC��������ֱ���Լ�ʣ��ʱ��Ϊ0
    remain(result(count))=work-wash(result(count));%��װ�ϵ�CNC��ʼ��һ�ι�������������ϴʱ��װ�ϵ�CNCҲ�ڹ�������˵�RGV�ֿɶ�ʱ��̨CNC�Ѿ���������ϴ�����ʱ��
    wash(result(count))=30;
    j=result(count);
end

save('simulation1_2.mat');
