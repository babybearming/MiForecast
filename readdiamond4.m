function gedianvalue = readdiamond4( header,varvalue,lon,lat )
%READDIAMOND4 处理diamond4类数据
%   提取特定经纬度的值
longeju=header(1);
latgeju=header(2);
startlon=header(3);
startlat=header(5);
lonnumofgedian=floor((lon-startlon)/longeju+1);
latnumofgedian=floor((lat-startlat)/latgeju+1);
gedianvalue=varvalue(latnumofgedian,lonnumofgedian);

end

