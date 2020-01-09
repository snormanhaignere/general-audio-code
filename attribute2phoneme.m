function phn = attribute2phoneme (attrib,cmd,mode)
if ~exist('cmd','var') || isempty(cmd)
    cmd = [];
end
if strcmpi(cmd,'list')
    phn = {'voiced','unvoiced','sonorant','syllabic','consonantal','approximant','plosive','fricative','nasal',...
        'strident','labial','coronal','dorsal','anterior','front','back','high','low','obstruent'};
    return;
end

switch lower(attrib)
    case 'voiced'
        phn = {'Z','V','DH','B','D','G','CH','JH'};%'L','R','M','N','NG',
    case 'unvoiced'
        phn = {'TH','F','S','SH','P','T','K'};
    case 'sonorant'
        phn = {'AA','AO','OW','AH','UH','UW','IY','IH','EY','EH','AE','AW','AY',...
            'OY','W','Y','L','R','M','N','NG'};
    case 'syllabic'
        phn = {'AA','AO','OW','AH','UH','UW','IY','IH','EY','EH','AE','AW','AY',...
            'OY'};
    case 'consonantal'
        phn = {'L','R','DH','TH','F','S','SH','Z','V','P','T',...
            'K','B','D','G','M','N','NG'};
    case 'approximant'
        phn = {'W','Y','L','R'};
    case 'plosive'
        phn = {'P','T','K','B','D','G'};
    case 'strident'
        phn = {'Z','S','SH'};
    case 'labial'
        phn = {'P','B','M','F','V'};
    case 'coronal'
        %phn = {'d','t','r','l','n','s','z','sh'};
        phn = {'D','T','N','S','Z'};
    case 'anterior'
        phn = {'T','D','S','Z','TH','DH','P','B','F','V','M','N','L','R'};
    case 'dorsal'
        phn = {'k','g','ng'};
        phn = {'K','G','NG','SH'};
    case 'front'
        phn = {'IY','IH','EH','AE'};
    case 'back'
        phn = {'UW','UH','AO','AA'};
    case 'high'
        phn = {'IY','IH','UH','UW'};
    case 'low'
        phn = {'EH','AE','AA','AO'};
    case 'nasal'
        phn = {'M','N','NG'};
    case 'fricative'
        phn = {'F','V','S','Z','SH','TH'};%,'DH'
    case 'semivowel'
        phn={'W','L','R','M','N','NG','Y'};%
    case 'obstruent'
        phn={'DH','TH','F','S','SH','Z','V','P','T',...
            'K','B','D','G'};


end