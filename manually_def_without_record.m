function positionlist=manually_def_without_record(ref,boxAll)

disp('Press   f   if you finish define all boxes.');

defaultbox=[round(size(ref,1)/2)-400,round(size(ref,1)/2)+400,round(size(ref,2)/2)-300,round(size(ref,2)/2)+300];

    refimg=figure;
    imshow(ref);
    hold on;

 positionlist=[];
 bflag=0;
    wid=1;
    spp=1;
    while 1
        if wid>length(boxAll) 
            boxx=defaultbox;
        else
            boxx=boxAll{wid};
        end
        box=[boxx(3), boxx(1), boxx(4)-boxx(3), boxx(2)-boxx(1)];
        hit = imrect(gca,box);
        fcn = makeConstrainToRectFcn('imrect',get(gca,'XLim'),get(gca,'YLim'));
        setPositionConstraintFcn(hit,fcn);

        while 1
            while 1
            k = waitforbuttonpress;
            % 28 leftarrow
            % 29 rightarrow
            % 30 uparrow
            % 31 downarrow
            %104 f
            %114 r
                if k==1 %exclude mouse click
                    returnValue = double(get(gcf,'CurrentCharacter'));
                    break                
                end
            end
            if returnValue==28
                 delete(hit);
                 wid=wid-1;
                 if wid<=0
                    boxx=defaultbox;
                else
                    boxx=boxAll{wid};
                end
                 box=[boxx(3), boxx(1), boxx(4)-boxx(3), boxx(2)-boxx(1)];
                 hit = imrect(gca,box);
                 setPositionConstraintFcn(hit,fcn);
            elseif returnValue==29
                delete(hit);
                wid=wid+1;
                if wid>length(boxAll) 
                    boxx=defaultbox;
                else
                    boxx=boxAll{wid};
                end
                box=[boxx(3), boxx(1), boxx(4)-boxx(3), boxx(2)-boxx(1)];
                hit = imrect(gca,box);
                setPositionConstraintFcn(hit,fcn);
            elseif returnValue==31 %Press down to confirm using this box for adjusting
                break
            elseif returnValue==102 %Press 'f' to exit the entire manual process
                bflag=1;
                break
            elseif returnValue==114 %Press 'r' to redo the manual process
                bflag=2;
                break
            end

            if wid>length(boxAll) 
                wid=length(boxAll);
            elseif wid<=0
                wid=1;
            end
        end
        
        if  bflag==0
            pause; %Press any key if finish the adjusting
            position = getPosition(hit);
            delete(hit);
            wid=wid+1;
            positionlist=[positionlist; position];
            rectangle('Position', positionlist(spp,:), 'EdgeColor','r', 'LineWidth', 2);
            spp=spp+1;
        elseif  bflag==1
            break
        elseif bflag==2
            close(refimg);
            refimg=figure;
            imshow(ref);
            hold on;
            positionlist=[];
            bflag=0;
            wid=1;
            spp=1;
        end
    end
    close(refimg);
    clear('refimg');
end