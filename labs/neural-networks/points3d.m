function points3d(points,T,arched)
% POINTS3D plots first three columns of POINTS (each row is a point).
% T are classes of points (either as a vector of classes numbered from 1
% or as a 0-1 matrix coding).
% If a class of a point is encoded as nonpositive (or vector of nonpositives),
% the point is discarded.
% If ARCHED is passed, points are arched to the closest coordinate plane.

% By Lukasz Stafiniak 2005 lukstafi@gmail.com

labels = ['bo';'rx';'gd';'k*';'ys';'mv';'c+';'r^';'g<';'k>';'bp';'mh';'c.';'y*'];

if ~(prod(size(T))==length(T))
    [A,I]=max(T,[],2);
    T = I .* (A > 0);
end

hold on
for i=1:length(T)
    p=[points(i,1),points(i,2),points(i,3)];
    lab=labels(T(i),:);
    plot3(p(1),p(2),p(3),lab);
    if nargin > 2
        [A,I]=min(p); p0=p; p0(I)=0;
        p=[p0;p];
        H=line(p(:,1),p(:,2),p(:,3));
        set(H,'Color',lab(1));
    end
end
