clear

remainTime=8*3600;%��ʣ��ʱ�䣨�룩

work=580;%CNC����һ������Ҫ580�롣

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

%remain���б�ʾ��įCNC����Ҫremain(i)ʱ����ɹ���
remain=[0 0 0 0 0 0 0 0];

%reload(i)��ʾ��įCNC������������ʱ��
reload=[30 35 30 35 30 35 30 35];

%wash��ʾ�����Ϻ�������ϴ���ĵ�ʱ��
%һ��ʼ����CNC�����أ���������Ϻ�������ϴ����į����������Ϻ�wash(i)Ӧ��Ϊ30
wash=[0 0 0 0 0 0 0 0];

%total���б�ʾRGV������ͣ����CNC�����������һ��ǰ����įCNCΪ��װ�ϣ���total(i)ʱ���RGV�����ٴ��ж�
%������RGV�ƶ�ʱ�䣬CNC����ʱ������Ϻ���ϴʱ�䣩
%total=tm(1,:)+reload;%���ǳ�ʼ״̬
%����RGV���ӵ�j̨CNC��������total�Ĺ�ʽΪ:
%total=max(tm(j,:),remain)+reload+wash;
%�ƶ�ʱ��ͻ���ʣ�๤��ʱ������ֵ������������ʱ�����ϴʱ��
j=1;    %��RGV��ǰλ���ڵ�j̨CNC��һ��ʼRGV�ڵ�1̨CNCλ��

count=0;%RGVһ��������count��������
%����RGV��һ��ǰ����įCNC

%����̰���㷨�ҳ�һ����
while remainTime>0
    %���㵽��ÿ��CNC��Ϊ��װ�ϣ���ϴ��������ʱ��
    total=max(tm(j,:),remain)+reload+wash;
    %RGVѰ�ұ��κ�ʱ��̵�CNCΪ��װ��
    [mi,i]=min(total);%miΪminimum��i������Ϊ��Сֵ���±�
    
    count=count+1;
    remainTime=remainTime-mi;
    remain=max(remain-mi,[0 0 0 0 0 0 0 0]);%û�б�RGV��˵�CNC��������ֱ���Լ�ʣ��ʱ��Ϊ0
    remain(i)=work-wash(i);%��װ�ϵ�CNC��ʼ��һ�ι�������������ϴʱ��װ�ϵ�CNCҲ�ڹ�������˵�RGV�ֿɶ�ʱ��̨CNC�Ѿ���������ϴ�����ʱ��
    wash(i)=30;
    result(count)=i;
    j=i;
end
save('greedy1_2.mat','result');
