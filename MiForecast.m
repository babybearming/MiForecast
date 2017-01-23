clc;clear;
%初始化变量 
nyx = [
54428	40.0333 	117.4000 
54525	39.7333 	117.2833 
54523	39.3833 	117.0167 
54529	39.3500 	117.8167 
54619	38.9167 	116.9167 
54527	39.0833 	117.0667 
54528	39.2333 	117.1333 
54517	39.1000 	117.1667 
54526	39.0833 	117.3333 
54622	38.9833 	117.3333 
54645	38.8500 	117.4667 
54530	39.2333 	117.7667 
54623	39.0500 	117.7167 
];
stationNum=13;
name = {'蓟县';'宝坻';'武清';'宁河';'静海';'西青';'北辰';
        '市区';'东丽';'津南';'大港';'汉沽';'塘沽'};
% 预报时效，用于读取每天的EC文件
forecasttime1{1}={'.003' '.006' '.009' '.012' '.015' '.018' '.021' '.024'};
forecasttime1{2}={'.027' '.030' '.033' '.036' '.039' '.042' '.045' '.048'};
forecasttime1{3}={'.051' '.054' '.057' '.060' '.063' '.066' '.069' '.072'};
forecasttime1{4}={'.078' '.084' '.090' '.096'};
forecasttime1{5}={'.102' '.108' '.114' '.120'};
forecasttime1{6}={'.126' '.132' '.138' '.144'};
forecasttime1{7}={'.150' '.156' '.162' '.168'};
forecasttime1{8}={'.174' '.180' '.186' '.192'};
forecasttime1{9}={'.198' '.204' '.210' '.216'};
forecasttime1{10}={'.222' '.228' '.234' '.240'};
% 数据存储地址
tmppath=importdata('setup.ini');
infilepath1=tmppath{1}; % 写文本读取形式
outfilepath='.\selectTemp\';
if ~exist(outfilepath)
    mkdir(outfilepath);
end
resultpath='.\results\';
if ~exist(resultpath)
    mkdir(resultpath);
end
% 需读取的EC变量名称
elements={'D\1000\' 'DHGT24\1000\' 'DTMP24\1000\' 'R\1000\' 'uv\1000\' 'T\1000\' 'W\1000\'}; %D散度；dp变压；dt变温；R相对湿度；uv流场；T气温；W垂直速度 
elements1={'D' 'DHGT24' 'DTMP24' 'R' 'uv' 'T' 'W'}; %D散度；dp变压；dt变温；R相对湿度；uv流场；T气温；W垂直速度 
elnums=length(elements);%变量个数
% 起报日期设置
startdate=datestr(addtodate(datenum(date),-1,'day'));
enddate=datestr(addtodate(datenum(date),-1,'day'));
numofdates=datenum(enddate)-datenum(startdate)+1; %起报日期数 
thedates=yeilddates(startdate,enddate);
thedatesfile=num2str(thedates(:,1)*10000+thedates(:,2)*100+thedates(:,3));
display(['起报时间为',startdate,'的20时']);

for foreday=1:10
    display(['正在生成第',num2str(foreday),'天的预报']);
forecasttime=forecasttime1{foreday};
forecastnums=length(forecasttime);%每天不同预报时效总文件数
display('.......');
for el=1:elnums
infilepath=[infilepath1 elements{el}]; %各EC变量地址
    for dd=1:numofdates
        for ff=1:forecastnums
        try
            filename=[thedatesfile(dd,3:end) '20' forecasttime{ff}];
            M=importdata([infilepath filename]);
            varvalue=M.data;
            header=str2num(M.textdata{5,:});
                for i=1:13
                    stationvalue(i)=readdiamond4(header,varvalue,nyx(i,3),nyx(i,2)); %读取EC变量
                end
            outfilepathnew=[outfilepath elements{el}];
                if ~exist(outfilepathnew)
                    mkdir(outfilepathnew);
                end
            dlmwrite([outfilepathnew filename],stationvalue);
         catch
            filename;
        end
        end
    end
end
display('.....');
% clearvars -except thedatesfile nyx elements elements1 forecasttime startdate enddate
% clc;

stationId=nyx(:,1)';

infilepath2='.\selectTemp\';
outfilepath2='.\merge\';
if ~exist(outfilepath2)
    mkdir(outfilepath2);
end

for el=1:elnums
infilepath=[infilepath2 elements{el}];
    for ff=1:forecastnums
        Dshixiao=nan(numofdates,14);
        for dd=1:numofdates 
            Dshixiao(dd,1)=str2num(thedatesfile(dd,1:end));
           try
            filename=[infilepath thedatesfile(dd,3:end) '20' forecasttime{ff}];
            M=dlmread(filename);
            Dshixiao(dd,2:end)=M;
           catch
            filename;
           end
        end
     format long g
     dlmwrite([outfilepath2 elements1{el} forecasttime{ff} '.txt'],Dshixiao,'precision','%.2f','delimiter',' ','newline','pc');   
    end
end

% clearvars -except elements1 forecasttime
% clc;
display('...');
cd '.\merge\'
    for j=1:forecastnums
        for k=1:elnums               
            temp=dlmread([elements1{k} forecasttime{j} '.txt']);
            for i=1:stationNum
                stationForeData(:,k,i)=temp(:,i+1);  
            end
        end
        foreDatas{j}=stationForeData;
    end
% 各时次求平均
foreDatassum=0;
count=0;
for i=1:forecastnums
    count=count+1; %时次计数
   foreDatassum=foreDatassum+foreDatas{i};
end
for i=1:stationNum
    EC_data1{i}=foreDatassum(:,:,i)/count;
end

display('.');
cd '..'
save EC_data1.mat EC_data1

load mi.mat
load foreDatapj
load EC_data1

startdate=datestr(addtodate(datenum(date),-1,'day'));
enddate=datestr(addtodate(datenum(date),-1,'day'));
forelen=length(foreDatapj); 
stationNum=length(mi);


foreData024=foreDatapj;

allNum=213;

for i=1:stationNum
allData{i}=[foreData024{i}(1:allNum,1) foreData024{i}(1:allNum,4:end) mi{i}(2:allNum+1,:)]; %暂时删除dp和dt数据
end

for i=1:stationNum
[h l]=find(isnan(allData{i}));
h=unique(h);
allData{i}(h,:)=[];
end

for i=1:stationNum
  traindata=allData{i}(:,1:end-1);
  target_trainData=allData{i}(:,end);
  testdata=[EC_data1{i}(:,1) EC_data1{i}(:,4:end)];
 [class{i},err_fit] = classify(testdata,traindata,target_trainData);
 outclass(:,i)=class{i}(:);

 tree=fitctree(traindata,target_trainData); % 使用训练数据构建决策树
 treeoutdata(foreday,i)=predict(tree,testdata);% 对测试数据预测
end
stationid=nyx(:,1)';
outdata(foreday,:)=outclass;
end
%结果输出
display('保存结果文件至results文件夹');
cd .\results
outdata=[stationid;outdata];
treeoutdata=[stationid;treeoutdata];
for i=1:stationNum
    csvwrite([startdate,'_Forecast_1-10day.csv'],outdata);
    csvwrite([startdate,'_Forecast_1-10day_Tree.csv'],treeoutdata);
end
