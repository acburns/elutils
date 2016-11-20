function log_error(err, varargin)
% log_error(err,['force_save',false])
% logs an error to the errors table

sessid = utils.inputordefault('sessid', 0, varargin);
force_save = utils.inputordefault('force_save', false, varargin);
caught = utils.inputordefault('caught',0, varargin);
comment = utils.inputordefault('comment',[],varargin);
if nargin == 0
	err = lasterror();
end

sqlS.rigid = db.getRigID();
if isempty(sqlS.rigid)
	if force_save
		sqlS.rigid = 0;
	else
		fprintf(1,'Error logging by default only works on real rigs. Use [force_save, 1] to override');
		return
	end
end
sqlS.ip = db.get_ip();
sqlS.message = err.message;
sqlS.identifier = err.identifier;
sqlS.caught = caught;
if ~isempty(comment)
	commentid = db.log_comment('met.error_log', comment);
	sqlS.commentid = commentid;
end

if sessid>0
	sqlS.sessid = sessid;
end


tmp = json.mdumps(err.stack,'compress',false);
% We can't handle struct arrays at this time convert to cell array of structs.	

if ~isempty(tmp)
	sqlS.stack=tmp;
end
	

dbc = db.labdb.getConnection();

dbc.saveData('met.error_log', sqlS);