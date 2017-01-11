function out = mloads(jstr, varargin)
% out = mdumps(obj, ['compress'])
% function that takes a matlab object (cell array, struct, vector) and converts it into json. 
% It also creates a "sister" json object that describes the type and dimension of the "leaf" elements.  
    
    if isempty(jstr)
        out = {};
        return;
    end

    if ischar(jstr)
        decompress = false;    
    elseif char(jstr(1))=='{'
        decompress = false;
        jstr = char(jstr(:))';
    else
        decompress = true;
    end

    decompress = utils.inputordefault('decompress',decompress,varargin);

    if decompress
        jstr = char(utils.zlibdecode(jstr));
    end

    bigJ = json.fromjson(jstr);

    out = bigJ.vals;
    meta = bigJ.info;

    out = applyinfo(out, meta);

end

function vals = applyinfo(vals, meta)
    
    if isfield(meta,'type__')
        % Then we are a leaf node
        tsize =double([meta.dim__{1} meta.dim__{2}]);
        tnumel = prod(tsize);
        switch(meta.type__)
        case {'cell', 'struct'}
            for cx = 1:tnumel
                vals{cx} = applyinfo(vals{cx}, meta.cell__{cx});
            end
            if strcmp(meta.type__, 'struct') % This is a struct array
                vals = [vals{:}];
            end
            vals = reshape(vals, tsize);
            
        case 'char'
            vals = char(vals);
        case 'double'
            if tnumel == 1
                vals = double(vals);
            else
                vals = double([vals{:}]);
                vals = reshape(vals, tsize);
            end
        otherwise
            f = @(x) cast(x, meta.type__);
            if tnumel == 1 || strcmp(meta.type__, 'char')
                vals = f(vals);
            else
                 vals = cellfun(f, vals);
              %  vals = cell2mat(vals);
                 vals = reshape(vals, tsize);
            end

        end
    else
        fnames = fieldnames(meta);
        for fx = 1:numel(fnames)
            vals.(fnames{fx}) = applyinfo(vals.(fnames{fx}), meta.(fnames{fx}));
        end 
    end
end


