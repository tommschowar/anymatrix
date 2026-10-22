function P = am_properties

P = {
    'baitsample', structp('random',1, 'symmetric',1, 'sparse',1, 'parameter_dependent',{'adjacancy_matrix','rand','rand'})
    'curvature', structp('rectangular',1, 'parameter_dependent',{'adjacancy_matrix','int'})
    'erdrey', {'random', 'symmetric', 'sparse'}
    'geo', {'random', 'symmetric', 'sparse'}
    'gilbert', {'random', 'symmetric', 'sparse'}
    'kleinberg', {'random', 'symmetric', 'sparse'}
    'lap', structp('random',1, 'symmetric',1, 'sparse',1, 'parameter_dependent',{'adjacancy_matrix','bool'})
    'lockandkey', {'random', 'symmetric', 'sparse'}
    'mht', structp('random',1, 'sparse',1, 'parameter_dependent',{'adjacancy_matrix','int'})
    'pagerank', structp('random',1, 'sparse',1, 'parameter_dependent',{'adjacancy_matrix','rand'})
    'pathlength', structp('random',1, 'symmetric',1, 'sparse',1, 'parameter_dependent',{'adjacancy_matrix'} )
    'pref', {'random', 'symmetric', 'sparse'}
    'renga', {'random', 'symmetric', 'sparse'}
    'rewire', structp('random',1, 'symmetric',1, 'sparse',1, 'parameter_dependent',{'adjacancy_matrix'})
    'short', structp('random',1, 'symmetric',1, 'sparse',1, 'parameter_dependent',{'adjacancy_matrix'})
    'smallw', {'random', 'symmetric', 'sparse'}
    'sticky', {'random', 'symmetric', 'sparse'}
    'unisample', structp('random',1, 'symmetric',1, 'sparse',1, 'parameter_dependent',{'adjacancy_matrix','rand'})
};
% parameter_dependent:
%       rand        value (scalar) in [0 1]
%       int         integer (scalar)
%       bool        boolean (scalar)
