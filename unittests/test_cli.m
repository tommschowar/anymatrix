TTEST init

TESTCASE all
[~,m] = EXPECT_NTHROW( @() anymatrix('all') );
EXPECT_CLASS( m, 'cell' );
EXPECT_ANYOF( 'contest/erdrey', m );  % erdrey.m does not return properties
EXPECT_ANYOF( 'matlab/hankel', m );  % only exists in `am_properties.m`
EXPECT_ANYOF( 'hadamard/complex_hadamard', m );
EXPECT_ANYOF( 'hadamard/hadamard', m );
EXPECT_ANYOF( 'gallery/qmult', m );



TESTCASE contents
EXPECT_NTHROW( @() anymatrix('contents','matlab') );
EXPECT_THROW( @() anymatrix('contents','wrong_group'), 'group ID was not found.' );
% missing test for group with missing `Contents.m`

TESTCASE groups
[~,g] = EXPECT_NTHROW( @() anymatrix('groups') );
EXPECT_CLASS( g, 'cell' );
EXPECT_ANYOF( 'core', g );
EXPECT_NTHROW( @() anymatrix('groups','nessie') );

TESTCASE help
EXPECT_STRCONTAINS( @() anymatrix('help'), 'Interface for accessing the Anymatrix collections.' );
EXPECT_STRCONTAINS( @() anymatrix('help', 'gallery/qmult'), 'Pre-multiply matrix by random orthogonal matrix.' );
EXPECT_STRCONTAINS( @() anymatrix('help', 'matlab/toeplitz'), 'Toeplitz matrix' );
EXPECT_STRCONTAINS( @() anymatrix('help', 'nessie/traincorr'), 'Correlation matrix associated with Scottish train travel times.' );

TESTCASE lookfor
if ~getenv('CI')
    EXPECT_THROW( @() anymatrix('lookfor'), 'Not enough input arguments.' );
    [~,m] = EXPECT_NTHROW( @() anymatrix('lookfor', 'Generate') );
    EXPECT_ANYOF( 'core/erdrey', m );
end

TESTCASE properties
SECTION all
    [~,p] = EXPECT_NTHROW( @() anymatrix('properties') );
    EXPECT_CLASS( p, 'cell' );
    EXPECT_ANYOF( 'permutation', p );

SECTION matrix
    [~,p] = EXPECT_NTHROW( @() anymatrix('properties','regtools/gravity') );
    EXPECT_ANYOF( 'scalable', p );

SECTION property
    [~,m] = EXPECT_NTHROW( @() anymatrix('properties','stochastic') );
    EXPECT_ANYOF( 'core/stoch_cesaro', m );
    
    [~,m] = EXPECT_NTHROW( @() anymatrix('properties','stochastic & permutation or ~square') );
    EXPECT_ANYOF( 'core/uptraporth', m );
    EXPECT_ANYOF( 'nessie/gene', m );
    EXPECT_TRUE( ~any(strcmp(m,'core/stoch_cesaro')) );  % has properties returned by function itself

% TESTCASE root_path
% EXPECT_NTHROW( @() anymatrix('root') );

% TESTCASE path
% EXPECT_THROW( @() anymatrix('path'), 'Not enough input arguments.' );
% EXPECT_NTHROW( @() anymatrix('path','matlab/hankel') );
% EXPECT_NTHROW( @() anymatrix('path','gallery/qmult') );
% EXPECT_NTHROW( @() anymatrix('path','core/bidiag_alt') );
% EXPECT_NTHROW( @() anymatrix('path','nessie/gene') );

TESTCASE scan
EXPECT_NTHROW( @() anymatrix('scan') );

TESTCASE sets
EXPECT_NTHROW( @() anymatrix('sets') );
EXPECT_NTHROW( @() anymatrix('sets','my_set') );

TESTCASE test
EXPECT_NTHROW( @() anymatrix('test') );
EXPECT_NTHROW( @() anymatrix('test','matlab') );
EXPECT_NTHROW( @() anymatrix('test','hadamard') );

TESTCASE generate-matrix
EXPECT_NTHROW( @() anymatrix('hadamard/hadamard',4) );
EXPECT_NTHROW( @() anymatrix('core/bidiag_alt',4) );
EXPECT_NTHROW( @() anymatrix('gallery/qmult',4) );
EXPECT_NTHROW( @() anymatrix('matlab/hankel',[1 2 3]) );





