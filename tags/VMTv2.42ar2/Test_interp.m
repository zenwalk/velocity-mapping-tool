%Test_interp

clear all

%test interpolation methods

Z = peaks(100);
[ny nx]=size(Z);
[X Y]=meshgrid(1:nx,1:ny);

% define a grid
%x = 0:1:100;
%y = 0:1:100;

%[X,Y] = meshgrid(x,y);

% Define a surface
%Z = sind(X) .* sind(Y); 


%figure(1); clf; 
%contour(X,Y,Z,30,'Fill','on','Linestyle','none')


% Add Nans
Z(90:100,:) = nan;
Z(1:10,:) = nan;
Z(35,72) = nan;
Z(12,12) = nan;
Z(5,76) = nan;
Z(39,100) = nan;
Z(40,100) = nan;
Z(41,100) = nan;
Z(100,39) = nan;
Z(100,40) = nan;
Z(100,41) = nan;

% Replot

figure(1); clf; 
contour(X,Y,Z,30,'Fill','on','Linestyle','none'); hold on
plot(X,Y,'r.','MarkerSize',3) 

pause

% Interpolate to smaller grid
x2 = 1:0.5:100;
y2 = 1:1:100;

[X2,Y2] = meshgrid(x2,y2);

Z2 = interp2(X,Y,Z,X2,Y2);

%Replot
figure(2); clf; 
contour(X2,Y2,Z2,30,'Fill','on','Linestyle','none'); hold on
plot(X,Y,'w.','MarkerSize',3); hold on
plot(X2,Y2,'r.','MarkerSize',3)

%Test smoothing
xn = 20;
yn = 20;

matrixOut = smooth2a(Z2,yn,xn);
figure(3); clf; 
contour(X2,Y2,matrixOut,30,'Fill','on','Linestyle','none'); hold on
plot(X,Y,'w.','MarkerSize',3); hold on
plot(X2,Y2,'r.','MarkerSize',3)
colorbar

[nma2Out] = nanmoving_average2(Z2,yn,xn);
figure(4); clf; 
contour(X2,Y2,nma2Out,30,'Fill','on','Linestyle','none'); hold on
plot(X,Y,'w.','MarkerSize',3); hold on
plot(X2,Y2,'r.','MarkerSize',3)
colorbar


% Test method 2
[r,c] = find(isnan(Z) == 0);
I = sub2ind(size(Z), r, c);

return

Z3 = interp2(x(c), y(r), Z(I), X2, Y2);

%Replot
figure(3); clf; 
contour(X2,Y2,Z3,30,'Fill','on','Linestyle','none'); hold on
plot(X,Y,'w.','MarkerSize',3); hold on
plot(X2,Y2,'r.','MarkerSize',3)

%
v = lininterp2(X, Y, V, x, y)
