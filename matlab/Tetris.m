function Tetris
load('shape.mat','shape');
block_size = 30;
rc = [20,10];
idTab = [2,3,4,1,6,7,8,5,10,11,12,9,14,13,16,15,18,17,19];
color_arr = ['w','r','g','b','y','m','c','k'];
rc2 = [rc(2),rc(1)]*block_size;
data = zeros(rc);
blocks = cell(rc);
grade = 0;
gamestate = 0;
cur_block = struct('id',0,'data',[],'row',0,'col',0,'cur_r',0,'cur_c',0);
hf = figure('Units','Pixels','Position',[500,100,rc2+[200,200]],'KeyPressFcn',@myKey);
ha = axes(hf,'Units','Pixels','Position',[100,100,rc2],'XLim',[1,rc2(1)],'YLim',[1,rc2(2)],'NextPlot','add');
ht = timer('ExecutionMode','fixedRate','Period',0.5,'TimerFcn',@myTimer);
uicontrol(hf,'Unit','pixels','Position',[10,720,100,30],'style','text','string','ตรทึ');
tips = uicontrol(hf,'Unit','pixels','Position',[110,720,100,30],'style','edit','string','0');
Init();
    function ClearBlock(sr,sc,lr,lc)
        data(sr:sr+lr-1,sc:sc+lc-1) = 0;
        Refresh(sr,sc,lr,lc);
    end
    function Refresh(sr,sc,lr,lc)
        er = sr+lr-1;
        ec = sc+lc-1;
        for i=sr:er
            for j=sc:ec
                set(blocks{rc(1)-i+1,j},'FaceColor',color_arr(data(i,j)+1));
            end
        end
    end
    function SetBlock(block,r,c)
        sz = size(block);
        ClearBlock(cur_block.cur_r,cur_block.cur_c,sz(1),sz(2));
        data(r:r+sz(1)-1,c:c+sz(2)-1) = data(r:r+sz(1)-1,c:c+sz(2)-1) + block;
        cur_block.cur_r = r;
        cur_block.cur_c = c;
        Refresh(r,c,sz(1),sz(2));
    end
    function GetNewBlock(id,flag)
        cur_block.id = id;
        cur_block.data = shape{id};
        cur_block.row = size(cur_block.data,1);
        cur_block.col = size(cur_block.data,2);
        if(flag == 1)
            cur_block.cur_r = 1;
            cur_block.cur_c = 4;
        end
        SetBlock(cur_block.data,cur_block.cur_r,cur_block.cur_c);
        Refresh(cur_block.cur_r,cur_block.cur_c,cur_block.row,cur_block.col);
    end
    function Init
        for i=1:rc(1)
            for j = 1:rc(2)
                blocks{i,j} = rectangle(ha,'Position',[[j-1,i-1]*block_size+1,block_size,block_size],'FaceColor','w');
            end
        end
        GetNewBlock(randi([1,19]),1);
    end
    function len = MaxDownDistance
        mc = cur_block.col;
        cnts = zeros(mc,1);
        ir = cur_block.cur_r;
        boundary = cur_block.cur_r + cur_block.row - 1;
        if boundary >= rc(1)
            len = 0;
            return;
        end
        for i = 1:mc
            ic = cur_block.cur_c+i-1;
            if(all(data(boundary:boundary+1,ic))~=0)
                cnts(i) = 0;
                break;
            end
            old = data(ir,ic);
            for j = ir+1:rc(1)
                new = data(j,ic);
                if(old ~= 0  && new == 0)
                    cnts(i) = 1;
                elseif(old == 0 && new == 0)
                    cnts(i) = cnts(i) + 1;
                elseif(old == 0 && new~= 0 && j > boundary)
                    break;
                end
                old = new;
            end
        end
        len = min(cnts);
    end
    function ret = RemoveRows
        ret = 0;
        remove = 0;
        reserve = [];
        for i=rc(1):-1:1
            if(all(data(i,:)==0))
                break;
            end
            if(any(data(i,:)==0))
                reserve = [reserve,i];
            else
                remove = remove + 1;
            end
        end
        reserve = flip([reserve,i:-1:1]);
        if(remove ~= 0)
            ret = sum(1:remove)*10;
            data(remove+1:end,:) = data(reserve,:);
            data(1:remove,:) = 0;
            Refresh(1,1,rc(1),rc(2));
        end
    end
    function DownRows(rows)
        if rows ~= 0
            SetBlock(cur_block.data,cur_block.cur_r + rows,cur_block.cur_c);
        else
            if cur_block.cur_r <= 2
                gamestate =0;
                stop(ht);
                set(tips,'String','gameover');
                return;
            end
            grade = grade + RemoveRows();
            set(tips,'String',num2str(grade));
            GetNewBlock(randi([1,19]),1);
        end
    end
    function myKey(~,e)
        switch e.Key
        case 's'
            gamestate = 1;
            start(ht);
        case 'uparrow'
            ClearBlock(cur_block.cur_r,cur_block.cur_c,cur_block.row,cur_block.col);
            GetNewBlock(idTab(cur_block.id),0);
        case 'downarrow'
            v = MaxDownDistance();
            DownRows(v);
        case 'leftarrow'
            v = cur_block.cur_c - 1;
            if v > 0
                SetBlock(cur_block.data,cur_block.cur_r,v);
            end
        case 'rightarrow'
            v = cur_block.cur_c + 1;
            if v + cur_block.col < rc(2)+2
                SetBlock(cur_block.data,cur_block.cur_r,v);
            end
        end
    end
    function myTimer(~,~)
        v = MaxDownDistance();
        if v~= 0
            v = 1;
        end
        DownRows(v);
    end
end