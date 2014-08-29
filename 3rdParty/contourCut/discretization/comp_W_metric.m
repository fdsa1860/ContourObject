function W_seg2 = comp_W_metric(W_seg, min_id, max_id, eig_vec, metric)
% W_seg2 = comp_W_metric(W_seg, e_area, min_id, max_id, radius, eig_vec, w);
% Compute weights according to embedding area

nb_segs = size(W_seg, 1);
[si,sj] = find(W_seg);

% Distance = area_i/2+area_j/2+span(i,j), angle(i)<angle(j)
span = angle(eig_vec(min_id(sj))) - angle(eig_vec(max_id(si)));
span = span + double(span < -pi)*2*pi;      % Across -pi
span = span - double(span < 0).*span*2;     % Backward sections

if strcmp(metric, 'radius')
    val =  abs(eig_vec([min_id(sj) max_id(sj) max_id(sj) min_id(sj)])).*...
        abs(eig_vec([min_id(si) max_id(si) min_id(si) max_id(si)]));
    val = max(val,[],2);
elseif strcmp(metric, 'area')
    val = abs(imag(eig_vec([min_id(sj) max_id(sj) max_id(sj) min_id(sj)]).*...
        conj(eig_vec([min_id(si) max_id(si) min_id(si) max_id(si)]))/2));
    val = max(val,[],2);
else
    val1 =  abs(eig_vec([min_id(sj) max_id(sj) max_id(sj) min_id(sj)])).*...
        abs(eig_vec([min_id(si) max_id(si) min_id(si) max_id(si)]));
    val1 = max(val1,[],2);
    val2 = abs(imag(eig_vec([min_id(sj) max_id(sj) max_id(sj) min_id(sj)]).*...
        conj(eig_vec([min_id(si) max_id(si) min_id(si) max_id(si)]))/2));
    val2 = max(val2,[],2);
    
    val1  = val1/max(val1);
    val2 = val2/max(val2);
    val = (val1+val2)*0.5;
end

if (any(val < 0))
    error('Negative weights detected.\n');
end
W_seg2 = sparse(si, sj, val, nb_segs, nb_segs);

