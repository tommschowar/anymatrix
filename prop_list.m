function P = prop_list
%PROP_LIST  List of properties recognized by anymatrix.
%   PROP_LIST is an n-by-1 cell array with a single supported property on
%   each row.

P = {
    'banded'
    'bidiagonal'
    'binary'                % Elements 0 or 1
    'block Toeplitz'
    'built-in'              % Included in the base Anymatrix collection.
    'circulant'
    'complex'
    'correlation'           % Symmetric positive (semi)definite with unit diagonal
    'defective'
    'diagonally dominant'
    'eigenvalues-explicitly-known'  % Part of the eigensystem is known explicitly  % Renamed from 'eigenvalues'
    'finite'                % all elements are finite
    'fixed size'            % The matrix dimension is fixed
    'hankel'                % Constant along the antidiagonals
    'hermitian'
    'hessenberg'
    'hyperbolic'
    'idempotent'
    'indefinite'
    'ill conditioned'       % The matrix is ill conditioned for some parameter values
    'infinitely divisible'  % A is symmetric positive semidefinite with nonnegative entries and A.^r is positive semidefinite for all r>=0 [2]
    'integer'               % All integer entries
    'inverse-explicitly-known'  % The inverse of the matrix is known explicitly  % Renamed from 'inverse'
    'invertible'            % A^2 = I
    'involutory'
    'kone'
    'matrixset'
    'M-matrix'
    'nilpotent'             % A^k = 0 for some positive integer k
    'nonzero'               % elementwise nonzero
    'nonnegative'           % All nonnegative entries
    'nonfinite'             % some elements are non-finite
    'normal'                % Normal, but not symmetric, Hermitian, orthogonal, or unitary  % XX
    'orthogonal'
    'parameter-dependent'   % Matrix depends on one or more parameters other than the dimension
    'permutation'
    'positive'              % All positive entries
    'positive-semidefinite'
    'positive definite'     % Applies for both Hermitian and symmetric. Includes semidefinite. XX Search for positive definite and rank deficient to locate singular semidefinite matrices
    'pseudo-orthogonal'     % Also known as J-orthogonal [10]
    'random'                % Random numbers are used in the construction
    'rank deficient'
    'real'
    'rectangular'
    'reducible'
    'scalable'              % The problem dimension (or a function of it) is a parameter. Not every dimension is necessarily supported.
    'singular values'
    'skew-hermitian'
    'skew-symmetric'
    'sparse'                % The matrix is stored in the MATLAB sparse format
    'square'
    'row-stochastic'        % Nonnegative with unit row sums  % renamed from 'stochastic'
    'symmetric'             % XX
    'toeplitz'
    'totally nonnegative'   % Every submatrix has nonnegative determinant
    'totally positive'      % Every submatrix has positive determinant
    'triangular'
    'tridiagonal'
    'unimodular'            % Integer entries and determinant +/-1
    'unitary'
    'vandermonde'
    };

end

%%
% [2] Rajendra Bhatia. Infinitely divisible matrices. Amer. Math. Monthly, 113(3):221–235, 2006. (Cited on p. 17.)
% [10] Nicholas J. Higham. J-orthogonal matrices: Properties and generation. SIAM Rev., 45(3): 504–519, 2003. (Cited on p. 18.)