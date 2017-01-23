function gedianvalue = readdiamond4( header,varvalue,lon,lat )
%READDIAMOND4 ����diamond4������
%   ��ȡ�ض���γ�ȵ�ֵ
longeju=header(1);
latgeju=header(2);
startlon=header(3);
startlat=header(5);
lonnumofgedian=floor((lon-startlon)/longeju+1);
latnumofgedian=floor((lat-startlat)/latgeju+1);
gedianvalue=varvalue(latnumofgedian,lonnumofgedian);

end

