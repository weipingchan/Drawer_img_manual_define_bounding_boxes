function ManuallyFindCoraseOutlines2(Img_directory,Code_directory,Result_directory,labelfileName)
% Turn off this warning "Warning: Image is too big to fit on screen; displaying at 33% "
% To set the warning state, you must first know the message identifier for the one warning you want to enable. 
warning('off', 'Images:initSize:adjustingMag');

%Read the file list in the Img_directory
img_ds = struct2dataset(dir(fullfile(Img_directory,'*.tiff')));
img_listing=img_ds(:,1);

imgFiletype='tiff'; %Default image file type
addpath(genpath(Code_directory)) %Add the library to the path
cd(Result_directory); %Move to the directory where the results will be stored.

disp('Start to create / find primary folders.');
%Create result directory
if ~exist('Drawer_result', 'dir')
    mkdir('Drawer_result');
end



for drawer=1:size(img_listing,1)
    if size(img_listing,1)>1
        template=img_listing(drawer,1).name{1}(1:end-9);
    else
       template=img_listing(drawer,1).name(1:end-9); 
    end
    %Read the image
    disp(['Start to analyze drawer: [',template,'].']);
    disp('Start to read images into memory.');
    img_names=fullfile(Img_directory,[template,'_940.',imgFiletype]); %Note that only the NIR940 tiff will be recongnized
    ref0 = import_img(img_names);
    disp('An image has been read into memory.');

    redres = imadjust(ref0(:,:,1));
    greenres = imadjust(ref0(:,:,2));
    blueres = imadjust(ref0(:,:,3));
    % Sum all color channels into an gray image.
    ref = mat2gray(imadd(imadd(redres,greenres),blueres));
    clear('ref0', 'redres', 'greenres', 'blueres');

    %Chek the special directory 'manual_boxes' in the Code_directory for
    %information of corresponding boxes information
    boxInfoDir='manual_boxes';
    boxinname=fullfile(Code_directory,boxInfoDir,[template,'_Boxes.mat']);
    box0=load(boxinname);
    fieldName=cell2mat(fieldnames(box0));
    boxAll=box0.(fieldName);
    
    %read the csv label file
    labelfile=readtable(fullfile(Code_directory,labelfileName));
    drawerlist=table2cell(labelfile(:,1));
    disp('The file including labels information is found.');

    %Find the corresponding labels and match with the number of specimens
    %Create temporary one if cannot find one
    subtemplate0=strsplit(template,'_');
    subtemplate1=strjoin(subtemplate0(1:end-1),'_');
    drawerID = find(all(ismember(drawerlist,subtemplate1),2));

    if isempty(drawerID)
        disp('CANNOT find corresponding drawer information.');
        position=manually_def_without_record(ref,boxAll); %The interactive procedure without the label reference
        disp('Total ',[num2str(length(position)),' specimens  have been manually defined.']);
    else
        disp('Find the corresponding drawer information.');
        specimenLabelList0=table2cell(labelfile(drawerID,:));
        specimenLabelList0(cellfun(@(specimenLabelList0) any(isnan(specimenLabelList0)),specimenLabelList0)) = []; %Remove NaN from the cell array
        specimenLabelList0=specimenLabelList0(~cellfun('isempty',specimenLabelList0));%remove empty cells
        specimenLabelList=specimenLabelList0(2:end);
        labelsppno=length(specimenLabelList);

        position=manually_def_with_record(ref,labelsppno,boxAll);%The interactive procedure with the label reference
        disp('All specimen boxes have been manually defined.');        
    end

    siz=size(ref);
    geometry_osize=cell(labelsppno,1);
    for i=1:labelsppno
          % Get the bounding box of the i-th object and enlarge it by 5 pixels in all
          % directions
          bb_i=ceil(position(i,:));
          idx_x=[bb_i(1)-5 bb_i(1)+bb_i(3)+5];
          idx_y=[bb_i(2)-5 bb_i(2)+bb_i(4)+5];
          if idx_x(1)<1, idx_x(1)=1; end
          if idx_y(1)<1, idx_y(1)=1; end
          if idx_x(2)>siz(2), idx_x(2)=siz(2); end
          if idx_y(2)>siz(1), idx_y(2)=siz(1); end
          geometry_osize{i}=[idx_y(1), idx_y(2), idx_x(1), idx_x(2)];
    end

        drawerInspectionDir='drawer_inspection';
        if ~exist(fullfile(Result_directory,'Drawer_result',drawerInspectionDir), 'dir')
            mkdir(fullfile(Result_directory,'Drawer_result',drawerInspectionDir));
        end
        %Save an image for drawer inspection
        drawervisoutname=fullfile('Drawer_result',drawerInspectionDir,[template,'_drawerSpecimenBoxes.jpg']);
        figout=figure('visible', 'off');
        imshow(ref);
        hold on;
        for spp=1:size(geometry_osize,1)
            original_box=geometry_osize{spp};
            position_box=[original_box(3), original_box(1), original_box(4)-original_box(3), original_box(2)-original_box(1)];
            rectangle('Position', position_box, 'EdgeColor','r', 'LineWidth', 1);
        end
        hold off;
        export_fig(figout, drawervisoutname, '-jpg', '-r100');
        disp('An image with identified boxes of specimens has been saved.');

        %Save the boxes
        boxInfoDir='manual_boxes';
        if ~exist(fullfile(Code_directory,boxInfoDir), 'dir')
            mkdir(fullfile(Code_directory,boxInfoDir));
        end

        boxoutname=fullfile(Code_directory,boxInfoDir,[template,'_Boxes.mat']);
        save(boxoutname,'geometry_osize');
        disp(['Boxes matrices for drawer: [',template,'] has been saved.']);
        disp(['Drawer ',num2str(drawer),' (',template,') of total ',num2str(size(img_listing,1)),' drawers has been identified.']);
  
    %Move those images having been analyzed to a subdirectory
    finishedDir='done';
    if ~exist(fullfile(Img_directory,finishedDir), 'dir')
        mkdir(fullfile(Img_directory,finishedDir));
    end
    movefile(fullfile(Img_directory,[template,'*.tiff']),fullfile(Img_directory,finishedDir));
    
    clear('geometry_osize', 'ref', 'figout', 'refimg', 'figure');
end
end