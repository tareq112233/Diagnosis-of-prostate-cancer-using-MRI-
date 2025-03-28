imgs="C:\Users\tareq\OneDrive\Desktop\the project code\5th project\cases\valdation1";
imgt = dir(fullfile(imgs, '*.png'));
datasheet = xlsread('C:\Users\tareq\OneDrive\Desktop\نظري مشروع خامسه\marksheet (1).csv');
data=num2str(datasheet(:,1));
patient_age=datasheet(:,3);
psa=datasheet(:,4);
prostat_volume=datasheet(:,6);
caseofprostate=datasheet(:,11);
psad=datasheet(:,5);
caseisup=datasheet(:,10);
[m, n]=size(imgt);
matrixtest=zeros(m,13);
j=1;k=1;
for i=1:3000
   t=imgt(j).name;
   tt="C:\Users\tareq\OneDrive\Desktop\the project code\5th project\cases\valdation1\"+t;
   t1=imread(tt);
   output=predict(trainedNetwork_1,t1);
   outb=output(:,1);
   outc=output(:,2);
   o=t(6:8);
   dd=datasheet(k,1);
   dd=num2str(dd);
   frst=dd(:,4);
   scnd=dd(:,5);
   hund=dd(:,3);
   datanum=[hund frst scnd];
   datanum2=str2num(datanum);
   if  o== datanum
      matrixtest(j,1)=outc;
      matrixtest(j,2)=patient_age(k,1);
      matrixtest(j,3)=psa(k,1);
      matrixtest(j,4)=prostat_volume(k,1);
      matrixtest(j,5)=psad(k,1);
      matrixtest(j,18)=caseofprostate(k,1);
      o=str2num(o)
      row = find(ex(:,1) == o);
        if isempty(ex(row,2))
            i=i+1
            j=j+1
            k=k+1
        else

%         matrixtest(j,:)=0;
%         k=k+1;
%       else
            matrixtest(j,6)=ex(row,2);
            matrixtest(j,7)=ex(row,3);
            matrixtest(j,8)=ex(row,4);
            matrixtest(j,9)=ex(row,5);
            matrixtest(j,10)=ex(row,6);
            matrixtest(j,11)=ex(row,7);
             matrixtest(j,12)=ex(row,8);
            matrixtest(j,13)=ex(row,9);
             matrixtest(j,14)=ex(row,10);
            matrixtest(j,15)=ex(row,11);
            matrixtest(j,16)=ex(row,12);
            matrixtest(j,17)=ex(row,13);
        end 
         j=j+1;
         k=k+1;
%       end
   else
      matrixtest(j,:)=0;
      k=k+1;

   end
end

%%%%%%%%%%%%%%%%%%
matrix1=zeros(96,1)
for h=1:101
    t=[matrixtest(h,1),matrixtest(h,2),matrixtest(h,3),matrixtest(h,4),matrixtest(h,5),matrixtest(h,6),matrixtest(h,7),matrixtest(h,8),matrixtest(h,9),matrixtest(h,10),matrixtest(h,11),matrixtest(h,12),matrixtest(h,13),matrixtest(h,14),matrixtest(h,15),matrixtest(h,16)];
    yfit = trainedModel1.predictFcn(t)
    matrix1(h,1)=yfit;
end
matrix1=[matrix1 matrixtest(:,17)]
tp1=0 ;tn1=0 ;fp1=0 ;fn1 = 0 ;
for o=1:404
   prcancer=matrix1(o,1)
   truecancer=matrix1(o,2)
   if prcancer>0.5 && truecancer == 1
       tp1=tp1+1
   elseif prcancer<0.5 && truecancer == 0
       tn1=tn1+1
   elseif prcancer>0.5 && truecancer == 0
       fp1=fp1+1
   elseif prcancer <0.5 && truecancer == 1
       fn1=fn1+1
   end
end
Accuracy= (tp1+tn1)/(tn1+tp1+fp1+fn1)
Sensitivity= (tp1)/(tp1+fn1)
specifty=tn1/(tn1+fp1)
