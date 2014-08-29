function [para] = current_para()
% Get default parameters

% Edge
para.pb_thres = 0.05;               % Threshold of edge detector

% Weight
para.bending = 3/2 - 1e-6;             % Changed: no more backslash here
para.nb_r = 15;                        % Connection radius
para.sigma_e = 1 - cos(pi/2.5);        % Sigma of bending energy
para.bounce_ratio = 0.1;               % How much flow is bounced back
para.diffuse_ratio = 0.05;             % How much flow is diffused to kNN
para.nb_neighbors = 100;               % Number of kNN
para.w_sample_rate = 4;                % Sample rate for kNN

% Eigen solver
para.eigs_maxit = 500;                 % Maximum iterations in eigensolver (eigs.m)
para.eigs_tol = 1e-5;                  % Tolerance of eigensolver
para.eigs_order = 'lr';                % Sorting order of the eigenvectors 
para.delta_min = 0;                    % Min/max/step size for searching over delta
para.delta_max = pi/4;
para.delta_step = 0.025;
para.algorithm = 'greedy';              % Algorithm to use. Options are:
                                       % 'exact' - the exact local maxima
                                       %     of the cost function found by
                                       %     searching over delta and
                                       %     calculating the eigenvectors
                                       %     of H(delta)
                                       % 'approx-right' - approximation using
                                       %     the right eigenvectors of P.
                                       % 'approx-left' - approximation using the
                                       %     left eigenvectors of P (scaled
                                       %     by Pi^-1).
                                       % 'approx-left-nonorm' - approximation
                                       %     using the left eigenvectors of
                                       %     P.
                                       % 'greedy' - traces contours in the
                                       %     original W matrix greedily.
                                       %     Doesn't make the graph smaller
                                       %     or calculate any eigenvectors.
                                       %     Fast.

% Parsing
para.real_thres = 1e-5;                % Remove real eigenvalues (imag<real_thres)
para.real_min = -1;                    % Remove eigenvalues whose real part is too small
para.mag_thres = 0.0005;               % Magnitude threshold for eigenvectors
para.nb_bin = 8;                       % Number of bins used
para.max_gap = 3;                      % Max gap to fill in
para.max_loop_per_eig = 100;           % Number of loops to find in one eigenvector
para.metric = 'area';                  % Metric to use in tracing cycles: 'area' or 'radius'
para.max_overlap = 0.75;               % Maximum overlap between contours
para.border = 5;                       % Number of pixels on outside of image to not have any nodes.
para.greedy_max_trace_ahead = 50;      % For the greed algorithm.  The number of pixels to look ahead when tracing.
para.greedy_num_samples = 500;         % Number of initialization locations to start tracing from.
para.find_closest_maxima = false;

para.max_winding = 3;                  % Max winding in the embedding space
para.max_supp = 0;                     % Use non-maximal suppression for contours in each eigenvector
para.check_shell = 0;
para.use_open_loop = 0;
para.combine_open_loop = 0;


% Misc
para.disp = 0;
