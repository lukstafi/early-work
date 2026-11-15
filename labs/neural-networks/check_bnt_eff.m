function [c, rate] = check_bnt_eff(engine, chckvar, data, data_tgt, comment)
% Check the classification efficiency of ENGINE against DATA_TGT.
%
% [C, RATE] = CHECK_BNT_EFF(ENGINE, CHCKVAR, DATA, DATA_TGT)
% ENGINE is the inference engine.
% CHCKVAR is the number of the target variable.
% DATA is the standard evidence cases matrix.
% DATA_TGT are the target classes (in the format accepted by CONFMAT).
%
% CHECK_BNT_EFF(ENGINE, CHCKVAR, DATA, DATA_TGT, COMMENT)
% Draw the confusion matrix figure with COMMENT string.

global check_bnt_eff_break_ctrl;

[nvar, nobs] = size(data);
ev  = cell(1,nvar);
check_bnt_eff_break_ctrl = 0;
wbar = waitbar(0, ['Checking efficiency of the model ', comment], 'CreateCancelBtn', ...
    'global check_bnt_eff_break_ctrl; check_bnt_eff_break_ctrl = 1');
y = [];
for i=1:nobs
    waitbar(i/nobs,wbar);
    ev = data(:,i);
    ev{chckvar} = [];
    eng = enter_evidence(engine, ev);
    mS = marginal_nodes(eng, chckvar);
    y(i) = mS.T(2);
    if check_bnt_eff_break_ctrl
        break;
    end
end
delete(wbar);
if nargout > 0
    [c, rate] = confmat(y', data_tgt(1:i,:));
end
if nargin > 4
    conffig2(y', data_tgt(1:i,:), ['BNET eff. ' comment]);
end
