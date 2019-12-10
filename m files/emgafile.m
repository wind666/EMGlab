function [status, Ann, filename] = emgafile (opt, p1)% EMGlab function for opening and saving annotation files.% Copyright (c) 2006-2009. Kevin C. McGill and others.% Part of EMGlab version 1.0.% This work is licensed under the Aladdin free public license.% For copying permissions see license.txt.% email: emglab@emglab.net	global EMGLAB EMG CURR DECOMP    Ann = [];    status = 0;	switch lower (opt);	case 'load'        if nargin==2;             type = p1;        else            type = 'annotation';         end;        % Change to prefered directory.		olddir = pwd;        path = get_preferred_path (type);                    try             cd (path);         catch        end;                % See which readers are available        reader_dir = fileparts(which('load_eaf'));        reader = dir (fullfile (reader_dir, 'load_*.m'));                % Konstantin's modification        % Was:%         extension{1,1} = '*.eaf';%         extension{1,2} = '*.eaf';%         p = 2;%         for i=1:length(reader);%             ext = reader(i).name(6:end-2);%             if ~strcmp (ext, 'eaf');%                 extension{p,1} = ['*.', ext];%                 extension{p,2} = ['*.', ext];%                 p = p+1;%             end;%         end;        % Now:        extension{1,1} = '*.ann';        extension{1,2} = '*.ann';        p = 2;        for i=1:length(reader);            ext = reader(i).name(6:end-2);            if ~strcmp (ext, 'ann');                extension{p,1} = ['*.', ext];                extension{p,2} = ['*.', ext];                p = p+1;            end;        end;        % End of modification                    % Select file.        if EMGLAB.matlab_version > 6;            % Konstantin's modification:            % Was:            %[file, path] = uigetfile (extension, 'Open Annotation file');            % Now:            [file, path] = uigetfile (extension, 'Open Annotation file', olddir);            % End of modification        else            [file, path] = uigetfile ('*', 'Open Annotation file');        end;		cd (olddir);        figure (EMGLAB.figure);        drawnow;                if ~ischar(file);            filename = '';            return;        else            filename = fullfile (path, file);        end;        remember_preferred_path (type, path);                % Load file.        i = find(file=='.');        type = file(i(end)+1:end);                try            [Ann, Fvar] = feval (['load_', type], filename);            if isfield(Fvar, 'template');                Ann.template = Fvar.template;            end;            status = 1;        catch             warndlg ({'Problems loading annotation file', lasterr});        end	case 'save'		if isempty (DECOMP.file) | DECOMP.readonly;			status  = emgafile ('save as');        else            [b, file, ext] = fileparts (DECOMP.file);            if isempty(ext);                ext = '.eaf';            end;                        if strcmp (ext, '.ann');                clist = CURR.chan;            else                clist = [1:EMG.nchannels];            end;              current_chan = CURR.chan;            Ann = struct ('time', [], 'unit', [], 'chan', []);            Tmp = struct ('chan', [], 'unit', [], 'data', [], 'index', [], 'rate', [], 'gain', [], 'units', []);            nt = 0;            for ic = clist;                emgvault ('channel', ic);                slist = emgslist (0);                if ~isempty(slist);                    Ann.time = [Ann.time; round(slist(:,1)*100000)/100000];                    Ann.unit = [Ann.unit;  slist(:,2)];                    Ann.chan = [Ann.chan; ic*ones(size(slist(:,1)))];                end;                gain = EMG.channel(ic).gain;                units = EMG.channel(ic).units;                for i=1:DECOMP.nunits;                    nt = nt+1;                    w = round(DECOMP.unit(i).waveform.sig * EMG.channel(ic).gain);                    Tmp(nt).chan = ic;                    Tmp(nt).unit =  i;                    Tmp(nt).data = w;                    Tmp(nt).index = floor((length(w)-1)/2);                    Tmp(nt).rate = EMG.rate;                    Tmp(nt).gain = gain;                    Tmp(nt).units = units;                end;            end;            emgvault ('channel', current_chan);            template = Tmp;                        switch ext;                case '.ann'                    fail = save_ann (DECOMP.file, Ann);                case '.eaf'                    fail = save_eaf (DECOMP.file, Ann, template);                otherwise                    fail = 1;            end;                        if ~fail;                file = DECOMP.file;                for ic = 1:EMG.nchannels;                    emgvault ('channel', ic);                    DECOMP.file = file;                    DECOMP.dirty = 0;                    DECOMP.readonly = 0;                end;                emgvault ('channel', current_chan);                status = 1;            end;            if ~status;%				errordlg ({'Unable to write annotation file.', DECOMP.file}, 'EMGlab');             end;		end;	case 'save as'		slist = emgslist (0);		if isempty (slist); return; end;        if nargin>1;            type = p1;        else            type = 'annotation';         end;                % Change to preferred directory		olddir = pwd;        path = get_preferred_path (type);        try            cd (path);         catch        end;        % See which readers are available        reader_dir = fileparts(which('save_eaf'));        reader = dir (fullfile (reader_dir, 'save_*.m'));        extension=[];                % Konstantin's modification:        % Was:%         extension{1,1} = '*.eaf';%         extension{1,2} = '*.eaf';%         p = 2;%         for i=1:length(reader);%             ext = reader(i).name(6:end-2);%             if ~strcmp (ext, 'eaf');%                 extension{p,1} = ['*.', ext];%                 extension{p,2} = ['*.', ext];%                 p = p+1;%             end;%         end;        % Now:        extension{1,1} = '*.ann';        extension{1,2} = '*.ann';        p = 2;        for i=1:length(reader);            ext = reader(i).name(6:end-2);            if ~strcmp (ext, 'ann');                extension{p,1} = ['*.', ext];                extension{p,2} = ['*.', ext];                p = p+1;            end;        end;        % End of modification                % Get the file name        [b, file] = fileparts (EMGLAB.emg_file);        % Konstantin's modification:        % Was:% 		[file, path, ix] = uiputfile (extension, ...%             'Save Annotation file as ...', file);        % Now:        if strcmp(file, 'imported')            [file, path, ix] = uiputfile (extension, ...                'Save Annotation file as ...', olddir);        else            [file, path, ix] = uiputfile (extension, ...                'Save Annotation file as ...', file);        end        % End of modification		cd (olddir);        if ~ischar (file);            status = 0;            return;        end;        remember_preferred_path (type, path);                %selected extension        ext=extension{ix,1};        ext=ext(2:end);                %Older versions of matlab do not add the extension         %to the end of the file        [fpath,fName,fExt] = fileparts(file);        if(~strcmp(ext,fExt))           DECOMP.file = fullfile (path, [file, ext]);        else           DECOMP.file = fullfile (path, file);        end                DECOMP.readonly = 0;          % Save the data        status = emgafile ('save');        	end;        function remember_preferred_path (type, path)         path = fileparts (path);  % normalize final separator        switch type            case 'annotation'                if strcmp (path, emgprefs('data_path'))                    emgprefs ('set', 'annotation_path', '#use data path');                else                    emgprefs ('set', 'annotation_path', path);                end;            case 'compare';                if strcmp (path, emgprefs ('data_path'))                    emgprefs ('set', 'compare_path', '#use data path');                elseif strcmp (path, emgprefs ('annotation_path'));                    emgprefs ('set', 'compare_path', '#use annotation path');                else                    emgprefs ('set', 'compare_path', path);                end;        end;    function path = get_preferred_path (type)        switch type            case 'annotation'                path = emgprefs ('annotation_path');            case 'compare'                path = emgprefs ('compare_path');        end;        if strcmp (path, '#use annotation path');            path = emgprefs ('annotation_path');        end;                    if strcmp (path, '#use data path')            path = emgprefs ('data_path');        end;