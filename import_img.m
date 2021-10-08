function corimg = import_img(file)
    img = imread(file);
    corimg = img;
    [imheight, imwidth, imchannel]=size(img);
    if imheight>imwidth
        corimg=imrotate(corimg, 90);
    end
end
