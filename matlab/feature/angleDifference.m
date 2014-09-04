function ang_d = angleDifference(curve)
% function angleDifference, a translation and rotation invariant feature
% Input:
% curve: N by 2 matrix, N is the number of points on a curve
% Output:
% ang_d: a vector of length N-2, angular difference

curve_d = diff(curve); % derivative of curve, to get translation invariance
ang = angle(complex(curve_d(:,1),curve_d(:,2)));
ang_d = diff(ang);      % derivative of angles, to get rotation invariance
ang_d( ang_d > pi ) = ang_d( ang_d > pi ) - 2*pi;   % remove discontinuity
ang_d( ang_d < -pi ) = ang_d( ang_d < -pi ) + 2*pi;

end