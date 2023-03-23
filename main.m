function []=splic()
%拼接两张图片

[reg2 reg3] = mregress(); %获取变换矩阵
Fx=@(x,y)reg2(1) + reg2(2)*x + reg2(3)*y;
Fy=@(x,y)reg3(1) + reg3(2)*x + reg3(3)*y;

filename1 = 'srow-col-1.jpg'; %载入图片
filename2 = 'srow-col-2.jpg';
imgA =imread(filename1);
imgB =imread(filename2);

imgC=uint8(zeros(1050,3080,3)); %创建新图

for i=1:1263
    for j=1:1451
        xx=round(Fx(j,i));
        yy=round(Fy(j,i));
        if(xx>0&&yy>0)
            imgC(yy,xx,1:3)=imgB((i),(j),1:3); %将'srow-col-2.jpg'中的坐标变换后写入
        end
    end
    
end
for i=1:1429
    for j=1:1920
        imgC(i,j,1:3)=imgA((i),(j),1:3); %写入参照照片'srow-col-1.jpg'
    end
    
end


imshow(imgC)
end

function [reg2 reg3]=mregress()
%对数据求出相应回归平面
load locA.txt % 导入第1个图片文件的SURf特征点
load locB.txt % 导入第2个图片文件的SURf特征点

y=locA([154 215 237],1); %经观察这三个点在所求回归平面上
x1=locB([154 215 237],1);
x2=locB([154 215 237],2);

X=[ones(3,1),x1,x2];

reg1=regress(y,X); %调用线性回归函数初步估计回归平面

F1=@(x,y)reg1(1) + reg1(2)*x + reg1(3)*y;

y=locA(:,1);
x1=locB(:,1);
x2=locB(:,2);

ax1=x1;
ax2=x2;
for i=1:311
    ay(i)=abs(F1(ax1(i),ax2(i))-y(i)); %计算残差
end

[ay,ind]=sort(ay); %对残差排序
ax1=ax1(ind);
ax2=ax2(ind);
y=y(ind);
%ans=[ax1,ax2,ay']

theta=2;
m=max(find(ay<theta)); %去除残差大于阈值的点
%m为剩余点个数，共196个
y=y(1:m,1);
ax1=ax1(1:m,1);
ax2=ax2(1:m,1);

X=[ones(m,1),ax1,ax2];

reg2=regress(y,X); %对剩余的点重新计算回归平面（求出x'的变换矩阵系数）
%-------------------------------------
y=locA(ind,2);
y=y(1:m,1);
reg3=regress(y,X); %对剩余的点重新计算回归平面（求出y'的变换矩阵系数）
%-------------------------------
end
