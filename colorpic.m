t2 = 'D:\the dataset\the selected slices\t2';
adc = 'D:\the dataset\the selected slices\adc';
hbv='D:\the dataset\the selected slices\hbv';
gland='D:\the dataset\the selected slices\gland';
t2f = dir(fullfile(t2, '*.dcm'));
adcf = dir(fullfile(adc, '*.dcm'));
hbvf = dir(fullfile(hbv, '*.dcm'));
glandf = dir(fullfile(gland, '*.dcm'));
j=0;k=0;i=0;
for i = 1:1000
    tfilename = sprintf('p%d%dt2.dcm',j,k);
    afilename = sprintf('p%d%dadc.dcm',j,k);
    hfilename = sprintf('p%d%dhbv.dcm',j,k);
    gfilename = sprintf('p%d%dgland.dcm',j,k);
    filepath = fullfile(hbv, hfilename);
    if exist(filepath, 'file')
        tfilepath = fullfile(t2, tfilename);
        afilepath = fullfile(adc, afilename);
        hfilepath = fullfile(hbv, hfilename);
        gfilepath = fullfile(gland, gfilename);
        tdicom = dicomread(tfilepath);
        adicom = dicomread(afilepath);
        hdicom = dicomread(hfilepath);
        gdicom = dicomread(gfilepath);
        [r w]=size(gdicom);
        ad=imresize(adicom,[r w]);    
        hb=imresize(hdicom,[r w]);
        stats = regionprops('table',gdicom,'Centroid');
        center=stats.Centroid;
        y=center(1);x=center(2);
        xmin=x-93;xmax=x+93;ymin=y-93;ymax=y+93;
        roi= [ymin ,xmin,ymax-ymin,xmax-xmin];
        cropt=imcrop(tdicom,roi);
        cropg=imcrop(gdicom,roi);
        cropa=imcrop(ad,roi);
        croph=imcrop(hb,roi);
        t2s=immultiply(cropg,cropt);
        hbvs=immultiply(cropg,croph);
        adcs=immultiply(cropg,cropa);
        outpict = imfuse(t2s,adcs,"falsecolor",'ColorChannels',[1 2 0]);
        out=imfuse(outpict,hbvs,"falsecolor",'ColorChannels',[1 0 2]);
%         imshow(out,[])
        imgfilename = sprintf('pimg %d%d.dcm',j,k);
        filepathimg = fullfile('C:\Users\tareq\OneDrive\Desktop\dicomproc',imgfilename);
        dicomwrite(out,filepathimg);
        if k==9
            k=-1;j=j+1;
        end
        k=k+1;
    else
        if k==9
           k=-1;j=j+1;
        end
        k=k+1;
    end
end


