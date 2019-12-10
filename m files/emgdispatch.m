function emgdispatch (down_click, up_click)	% EMGlab function that translates screen clicks into commands.% Copyright (c) 2006-2009. Kevin C. McGill and others.% Part of EMGlab version 1.0.% This work is licensed under the Aladdin free public license.% For copying permissions see license.txt.% email: emglab@emglab.net		global SETS CURR		normal = strcmp (down_click.type, 'normal');	shift  = strcmp (down_click.type, 'extend');	option = strcmp (down_click.type, 'alt');    doubleclick   = strcmp (down_click.type,'open');    moved = down_click.moved;		switch down_click.panel        	case 'SIG_resize_bar'       		emgscreen ('adjust', 'SIG', down_click.y_pxls - up_click.y_pxls);			case 'TMP_resize_bar'		emgscreen ('adjust', 'TMP', down_click.y_pxls - up_click.y_pxls);			case 'FIR_resize_bar'		emgscreen ('adjust', 'FIR', up_click.x_pxls - down_click.x_pxls);	    case 'map'        emgcursors ('focus', 'navigation', 'c', up_click.x_units);         	case 'navigation'        switch up_click.panel;		case 'navigation'            if strcmp (down_click.focus, 'firing');                emgcursors ('focus', 'firing', 'c', up_click.x_units);            elseif strcmp (down_click.focus, 'signal');                      emgcursors ('focus', 'signal', 'c', up_click.x_units);            end;        end;    case 'signal'		switch up_click.panel;		case 'signal'			if strcmp (down_click.object, 'text') & option;				emgaction ('delete spike', down_click.params, down_click.x_units);			elseif shift				emgaction ('identify spike', CURR.unit, up_click.x_units);			elseif normal	                emgaction ('show closeup', up_click.x_units);			end;		case 'template'            emgaction ('create unit', down_click.x_units);        case 'closeup'            emgaction ('show closeup', down_click.x_units - up_click.x_divs * SETS.closeup.timebase);		end;            case 'tempcursor'        switch up_click.panel        case 'tempcursor'            emgcursors ('focus', 'template', 'z', ceil(up_click.y_units));        end;     		case 'template'		[down_unit, down_time, occurrence_time] = whichtemplate (down_click);		switch up_click.panel		case 'signal';			emgaction ('identify spike', down_unit, up_click.x_units);				case 'template'			[up_unit, up_time] = whichtemplate (up_click);						if option                if ~strcmp(SETS.template.style, 'normal') & strcmp(down_click.object, 'signal');                    emgaction ('delete spike', down_unit, occurrence_time);                else                    emgaction ('delete unit', down_unit);                end;			elseif normal & down_unit == up_unit & ~moved                if isempty(occurrence_time);                    emgsettings ('select unit', down_unit, 'toggle');                else                    emgsettings ('select unit', down_unit); 					emgcursors ('focus', 'signal', 'c', occurrence_time); % + up_time);                end;			elseif normal & down_unit~=up_unit;				emgaction ('reorder units', down_unit, up_unit);			elseif shift & up_unit == down_unit & moved				emgaction ('shift template', down_unit, up_time - down_time);			elseif shift & up_unit ~= down_unit;				emgaction ('merge units', down_unit, up_unit);        %       elseif doubleclick     %           SETS.template.display=1;     %           SETS.template.first_unit=down_unit;     %           emgplot('templates');                             elseif shift;				emgaction ('add unit to closeup', down_unit);			end;				case 'closeup'			emgaction ('add unit to closeup', down_unit, up_click.x_units - down_time);					end;		case 'firing'		switch up_click.panel;		case 'firing'            			switch SETS.firing.style			case {'normal', 'diff'}                unit = round(up_click.y_units);                if normal & ~moved					emgsettings ('select unit', unit, 'noplot');					emgcursors ('focus', 'signal', 'c', up_click.x_units); 				elseif option					emgaction ('delete spike', unit, up_click.x_units);                end;			case 'ifr' 				if normal & ~isempty(down_click.params);					emgsettings ('select unit', down_click.params, 'noplot');				end;				emgcursors ('focus', 'signal', 'c', up_click.x_units);			end;					end;		case 'closeup'		switch up_click.panel;		case 'closeup'            if strcmp (down_click.object, 'unit')                if strcmp (down_click.drag, 'panel');                elseif normal & ~strcmp (down_click.drag, 'none');            					emgaction ('adjust closeup', down_click.params, ...                           up_click.x_units + down_click.offset);				elseif shift					emgaction ('show/hide closeup unit', down_click.params);                elseif option					emgaction ('delete closeup unit', down_click.params);                end;            elseif normal                emgaction ('adjust closeup');            end;		end;		otherwise 		switch down_click.object		case 'firing text'			if normal				emgsettings ('select unit', down_click.params, 'toggle');             elseif option			end;		end;							end;function [iu, toff, t] = whichtemplate (click)	global SETS SCREEN	S = SETS.template;	nrows = ceil (S.display / 10);	ncols = mod (S.display-1, 10) + 1;    y = click.y_divs/S.top/2 + .5;	row = ceil ((1-y) * nrows) -1; % zero based	col = ceil (click.x_divs/10 * ncols) - 1;  % zero based	iu = S.first_unit + row * ncols + col;	gap = 1 / ncols;	template_length = (S.right - (ncols-1)*gap) / ncols;	xoff = template_length/2 + col*(template_length + gap);	toff = click.x_units - xoff*S.timebase;    if strcmp(SETS.template.style, 'normal');        t = [];        return;    end;        isig = row*ncols + col + 1;    y = (click.y_divs-S.bottom)/(S.top-S.bottom);    y = y*nrows - row;    [ft0, ft1] = whattime (SETS.firing);    if ~isfield (click, 'object');        object = 'none';    else        object = click.object;    end;    if strcmp (object, 'signal');        px = get(SCREEN.template.signal(isig),'xdata');        py = get(SCREEN.template.signal(isig),'ydata');        d = (px-click.x_divs).^2 + (py-click.y_divs).^2;        k = find(d==min(d));        n = sum(isnan(d(1:k)))+1;        u = emgslist (iu, ft0, ft1);        t = u(n);    elseif strcmp (SETS.template.style, 'cascade') & y>0.25 & y<0.75;        t = ft0 + (.75-y)*2*(ft1-ft0);    else        t = [];    end;