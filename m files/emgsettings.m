function emgsettings (opt, p1, p2)% Handles settings associated with buttons and popups.% Copyright (c) 2006-2009. Kevin C. McGill and others.% Part of EMGlab version 1.0.% This work is licensed under the Aladdin free public license.% For copying permissions see license.txt.% email: emglab@emglab.net	global CURR SETS EMG DECOMP 		switch lower (opt);		case 'init'		CURR.band = 1;		CURR.chan = 1;        CURR.auxchan = 0;		CURR.color_scheme = emgprefs ('color_scheme');		CURR.unit = 0;        CURR.compare = 0;        CURR.swap = 0;		initialize_settings;		set_colors;	        SETS.auxiliary = struct ('highpass', 0, 'lowpass', inf, 'min', 0, 'max', 1);		emgsettings ('set popups');			case 'reset'		nbands = SETS.nbands;		nchans = EMG.nchannels;		SETS.signal.sensitivity = zeros(nchans, nbands);		SETS.signal.time = nan;        SETS.signal.aux = 0;		SETS.template.sensitivity = zeros(nchans, nbands);		SETS.template.first_unit = 1;        SETS.template.style = 'normal';		SETS.firing.sensitivity = 20;		SETS.firing.time = nan;		SETS.firing.style = 'normal';        SETS.firing.aux = 0;		SETS.closeup.sensitivity = zeros(nchans, nbands);		SETS.closeup.time = 0;		SETS.closeup.style = 'empty';		SETS.navigation.sensitivity = zeros(nchans, nbands);		SETS.navigation.time = nan;        SETS.navigation.timebase=1;        SETS.navigation.style = 'signal';        SETS.navigation.aux = 0;        SETS.auxiliary = struct ('highpass', 0, 'lowpass', inf, 'min', 0, 'max', 1);		CURR.band = 1;		CURR.chan = 1;        CURR.auxchan = 0;		CURR.unit = 0;        CURR.compare = 0;        CURR.swap = 0;		emgsettings ('set popups');			case 'colors'		set_colors;			case 'set popups'		if isempty (EMG);			nchans = 1;		else			nchans = EMG.nchannels;		end;		h = findobj ('tag', 'filter');		s = '';		for i=1:SETS.nbands;			f = SETS.band(i).frequency;			if f==0;				s = [s, 'unfiltered|'];			else				s = [s, sprintf('%i Hz|', f)];			end;		end;        s = [s, 'other'];		set (h, 'string', s, 'value', CURR.band);		h = findobj ('tag', 'channel');		s = sprintf ('Chan %i|', [1:nchans]);		set (h, 'string', s(1:end-1), 'value', CURR.chan);                h = findobj ('tag', 'lowpass');        set (h, 'string', ['0.5 Hz|1 Hz|2 Hz|4 Hz|8 Hz|16 Hz'], 'value', 3);                        	case 'set closeup style'		if strcmp (p1, 'normal') & strcmp(SETS.closeup.style, 'merge');			emgplot ('firing');		end;		SETS.closeup.style = p1;		case 'show all templates'		S = SETS.template;		nunits = DECOMP.nunits;        if nunits==0; return; end;        if S.first_unit > nunits;             SETS.template.first_unit = 1;        end;		n_to_show = nunits - S.first_unit + 1;		max_show = S.display_list(end);        if n_to_show > S.display & n_to_show > max_show			SETS.template.display = max_show;			SETS.template.first_unit = nunits - max_show + 1;		elseif n_to_show > S.display			i = min(find(S.display_list >= n_to_show));			SETS.template.display = S.display_list(i);		elseif n_to_show <= S.display-10;			SETS.template.display = ceil (n_to_show/10)*10;        end        if S.first_unit > nunits;            SETS.template.first_unit = max (1, nunits - SETS.template.display +1);        end;		case 'select unit'; %p1 = unit, p2 = ['normal'] | 'toggle' | 'noplot'        if strcmp (SETS.closeup.style, 'merge');             SETS.closeup.style = 'empty';            emgplot ({'closeup', 'firing'});        end;		if nargin<3; p2 = 'normal'; end;		if p1==CURR.unit & strcmp(p2, 'toggle');			CURR.unit = 0;		elseif p1>0 & p1<=DECOMP.nunits;			CURR.unit = p1;        else            CURR.unit = 0;		end;		emgplot ({'template colors', 'firing colors'});        if ~strcmp(p2, 'noplot');            emgplot ('signal annotation');        end;            case 'get aux settings'        S = EMG.source(1 - CURR.auxchan).channel(1);        SETS.auxiliary.highpass = S.highpass;        SETS.auxiliary.lowposs = S.lowpass;        SETS.auxiliary.min = S.min;        SETS.auxiliary.max = S.max;            case 'save aux settings'        S = SETS.auxiliary;        isource = 1 - CURR.auxchan;        EMG.source(isource).channel(1).hiahpass = S.highpass;        EMG.source(isource).channel(1).lowpass = S.lowpass;        EMG.source(isource).channel(1).min = S.min;        EMG.source(isource).channel(1).max = S.max;        EMG.source(isource).channel(1).name = EMG.thread(2).channel(1).name;            case 'aux dialog'        S = SETS.auxiliary;        d = [];        d = clerk ('add', d, 'name', 'string', EMG.thread(2).channel(1).name, {}, 1, 'Name')';        d = clerk ('add', d, 'highpass', 'double', S.highpass, {}, 1, 'High pass filter (Hz)');        d = clerk ('add', d, 'lowpass', 'double', S.lowpass, {}, 1, 'Low pass filter (Hz)');        d = clerk ('add', d, 'max', 'double', S.max, {}, 1, 'Display max');        d = clerk ('add', d, 'min', 'double', S.min, {}, 1, 'Display min');        [d, status] = gendialog (d, 'EMGlab Auxiliary signal settings', emgprefs ('font_size'));                if status;            EMG.thread(2).channel(1).name = d.name.value;            SETS.auxiliary.highpass = d.highpass.value;            SETS.auxiliary.lowpass = d.lowpass.value;            SETS.auxiliary.min = d.min.value;            SETS.auxiliary.max = d.max.value;        end;  			end;        function initialize_settings()	global SETS	senses = [0.1, 0.25, 0.5, 1, 2.5, 5, 10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10000, 25000, 50000];	SETS.nbands = 5;	SETS.band = struct (...		'frequency',	{0, 100, 250, 500, 1000}, ...		'temp_width',	{0, 0, 0, 0, 0});     	SETS.map = struct( ...		'left',			0, ...		'right',		10, ...		'bottom',		-1, ...		'top',			1, ...		'sensitivity',	1, ...		'tbase_list', 	1, ...		'timebase',		1, ...		'time_step', 	1, ...		'time',			nan);	SETS.tempcursor = struct( ...		'left',			0, ...		'right',		1, ...		'bottom',		0, ...		'top',			1, ...		'sensitivity',	1, ...		'tbase_list', 	1, ...		'timebase',		1, ...		'time_step', 	1, ...		'time',			0);    	SETS.navigation = struct( ...		'left',			0, ...		'right',		10, ...		'bottom',		-1, ...		'top',			1, ...		'sensitivity',	0, ...        'sens_list',    senses, ...		'tbase_list', 	[0.5,1,2,5,10], ...		'timebase',		1, ...		'time_step', 	1, ...		'time',			nan, ...        'grid',         0, ...        'aux',          0, ...        'style',        'signal');		SETS.signal = struct(...		'left',			0, ...		'right',		10, ...		'bottom',		-1, ...		'top', 			+1, ...		'tbase_list', 	[.001, .002, .005, .01, .02, .05, .1, .2, .5, 1], ...			'sens_list', 	senses, ...		'timebase', 	.01, ...		'sensitivity',	0, ...		'time', 		nan, ...		'time_step',	5, ...        'aux',          0, ...        'grid',         0);	SETS.template = struct(...		'left',			0, ...		'right',		10, ...		'bottom',		-1, ... % set by emgscreen		'top',			+1, ... % set by emgscreen		'tbase_list', 	[.001, .002, .005, .01, .02, .05], ...		'sens_list', 	senses, ...		'timebase', 	.01, ... 		'time',			0, ...		'sensitivity',	0, ...   	    'display_list', [1, 2, 5, 10, 20, 30],...		'display',		10, ...		'first_unit', 	1, ...        'style',        'normal', ...        'grid',         0);			SETS.firing = struct(...		'left',			0, ...		'right',		10, ...		'bottom',		0, ...		'top',			1, ...		'tbase_list', 	[.05, .1, .2, .5, 1, 2, 5, 10], ...		'sens_list', 	[10, 20, 40, 60, 100], ...		'timebase', 	.5, ...		'sensitivity',	20, ...		'time', 		nan, ...		'time_step',	1, ...        'lowpass',      2, ...		'style', 		'normal', ...        'aux',          0, ...        'grid',         0);	SETS.closeup = struct(...		'left',			-2.5, ...		'right',		+2.5, ...		'bottom',		-3, ...		'top', 			+1, ...		'tbase_list', 	[.0005, .001, .002, .005, .01, .02], ...		'sens_list', 	senses, ...		'timebase', 	.002, ...		'sensitivity',	0, ...		'time', 		nan, ...		'time_step',	1, ...		'chan',     	1, ...		'style',		'empty', ...        'grid',         0);function set_colors	global SETS				switch emgprefs ('color_scheme');						case 'paper'		SETS.colors = struct(...			'background',	[220, 220, 220] / 255, ...			'backgr_text',	[  0,   0,   0] / 255, ...            'menu',         [240, 240, 240] / 255, ...			'button',		[220, 220, 220] / 255, ...			'button_text',	[  0,   0,   0] / 255, ...			'popup',		[220, 220, 220] / 255, ...			'popup_text',	[  0,   0,   0] / 255, ...			'panel',		[255, 255, 255] / 255, ...			'panel_edge',	[180, 180, 180] / 255, ...			'panel_text',	[  0,   0,   0] / 255, ...			'signal', 		[  0,   0,   0] / 255, ...			'residual',		[160,  90,   6] / 255, ...			'reconstruct',	[  0,   0, 255] / 255, ...			'template',		[  0,  50, 255] / 255, ...			'selection',	[255,   0,   0] / 255, ...            'compare',      [150,  50,   0] / 255, ...            'aux',          [  0,  80, 130] / 255, ...			'waves',		[212    0   232                             179  179    0                               0  217  198                             232    0   20                              18  217    0                             232  141    0                               0   85  255                              96    0  232] / 255, ...			'graticule',	[ 50, 150, 100] / 255, ...			'cursor',		[183, 247, 156] / 255);					case 'custom'		SETS.colors = struct(...							'background',	[ 60,  60,  60] / 255, ...			'backgr_text',	[255, 255, 255] / 255, ...            'menu',         [200, 200, 200] / 255, ...			'button',		[140, 140, 140] / 255, ...			'button_text',	[  0,   0,   0] / 255, ...			'popup',		[140, 140, 140] / 255, ...			'popup_text',	[  0,   0,   0] / 255, ...			'panel',		[  0,   0,   0] / 255, ...			'panel_edge',	[ 76,  90,  76] / 255, ...			'panel_text',	[255, 255, 255] / 255, ...			'signal', 		[255, 255, 255] / 255, ...			'residual',		[190, 190,   0] / 255, ...			'reconstruct',	[  0, 255, 255] / 255, ...			'template',		[220, 220, 100] / 255, ...			'selection',	[200,  50, 100] / 255, ...            'compare',      [255, 160, 180] / 255, ...            'aux',          [  0,  80, 130] / 255, ...			'waves',		[233    0  255                             255  233    0                               0  255  233                             255    0   22                              22  255    0                             255  106    0                               0   85  255                             106   51  255]/255, ...			'graticule',	[ 50, 150,  50] / 255, ...			'cursor',		[  0,  75,   0] / 255);					case 'scope'		SETS.colors = struct(...							'background',	[  0,   0,   0] / 255, ...			'backgr_text',	[255, 255, 255] / 255, ...            'menu',         [200, 200, 200] / 255, ...			'button',		[120, 120, 120] / 255, ...			'button_text',	[  0,   0,   0] / 255, ...			'popup',		[255, 255, 255] / 255, ...			'popup_text',	[  0,   0,   0] / 255, ...			'panel',		[  0,   0,   0] / 255, ...			'panel_edge',   [  0,  40,   0] / 255, ...			'panel_text',	[255, 255, 255] / 255, ...			'signal', 		[255, 255, 255] / 255, ...			'residual',		[190, 190,   0] / 255, ...			'reconstruct',	[  0, 255, 255] / 255, ...			'template',		[220, 220, 100] / 255, ...			'selection',	[210,  30,  70] / 255, ...            'compare',      [255, 150, 180] / 255, ...            'aux',          [  0,  80, 130] / 255, ...			'waves',	    [233    0  255                             255  233    0                               0  255  233                             255    0   22                              22  255    0                             255  106    0                               0   85  255                             106   51  255]/255, ...			'graticule',	[ 50, 150,  50] / 255, ...			'cursor',		[ 25,  75,  25] / 255);						end;