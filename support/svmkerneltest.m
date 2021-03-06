function [y, dec, acc] = svmkerneltest(cl, K, varargin)
% SVMKERNELTEST
%  Y = SVMKERNELTEST(CL, K) test the SVM CL on the testing data K. CL
%  is a SVM obtained by SVMKERNELTRAIN(). K is the kernel matrix,
%  training vectors along the columns and test vectors along the rows.
%
%  [Y, DEC] = SVMKERNELTEST(...) returns also the value DEC of the
%  decision function(s) evaluated at each test vector. In order to
%  parse this value, you must refer to the LAB = CL.LABELS vector. For
%  a binary classifier LAB has two entries and DEC is a column vector,
%  with one entry per test vector. Each value represent the confidence
%  that the corresponding test vector class is LAB(1) as opposed to
%  LAB(2).
%
%  For a multiclass classification problem with L classes, LAB has L
%  entries DEC is a matrix. Each row contains the decision values of
%  the L(L-1)/2 classification subproblems LAB(1) vs LAB(2), LAB(1) vs
%  LAB(3) and so on. So for instance the second element of each row is
%  the confidence that the correspdonging test vector class is LAB(12
%  as opposed to LAB(3).
%
%  DEC is the value of the decision functions with the bias removed
%  (the bias is equal to - CL.LIBSVM_CL.RHO).
%
%  [Y, DEC, ACC] = SVMKERNELTEST(...) returns also the estimated
%  prediction accuracy (see the Labels option below).
%
%  REMARK. When caluclating K, the order of the training vectors must
%  match the order used to train the SVM (see SVMKERNELLEARN()).
%
%  Options:
%
%  Labels [[]]
%    Specify test labels (used only to compute accuracy).
%
%  Verbosity [0]
%    Set verbosity level.
%
%  Author:: Andrea Vedaldi

% AUTORIGHTS
% Copyright (C) 2008-09 Andrea Vedaldi
%
% This file is part of the VGG MKL Class and VGG MKL Det code packages,
% available in the terms of the GNU General Public License version 2.

y = [] ;
verb = 0 ;

for k=1:2:length(varargin)
  opt = lower(varargin{k}) ;
  arg = varargin{k+1} ;
  
  switch opt
    case 'verbosity'
      verb = arg ;
      
    case 'labels'
      y = arg ;

	 otherwise
      error(sprintf('Option ''%s'' unknown.', opt)) ;
  end  
end

if verb
  cats = unique(y) ;
  for c=cats
    nt(c) = sum(y == c) ;
  end
  Nt = sum(nt) ;

  fprintf('svmkerneltest: labels prop: ') ;
  for c=cats
    fprintf('%.2f %%', 100 * n(c) / N) ;
  end
  fprintf('\n') ;
end

% RBF transform
if cl.rbf
  K = exp(- cl.gamma * K) ;  
end

% --------------------------------------------------------------------
%                                                               Do job
% --------------------------------------------------------------------

% Nt = # test
% N  = # train
[Nt, N] = size(K) ;

if isempty(y), y = zeros(1,Nt) ; end
[y, acc, dec] = svmpredict(y(:), [(1:Nt)' K], cl.libsvm_cl) ;

% remove bias from dec
%dec = dec + cl.libsvm_cl.rho ;
