function [V] = VMT_RozovskiiV2(V,A)

% Computes the frame of reference transpositon as described in Kenworthy
% and Rhoads (1998) ESPL using a Rozovskii type analysis.

% Notes:
%     -The depth averaging currently linearly interpolates to the bed,
%      however we may want some other approach such as log law, etc.
%     -I extrapolate the velocity at the near surface bin to the water
%      surface for the depth averaging (ie, BC at u(z=0) = u(z=bin1))
%     -There are cases where the bin corresponding with the bed actually
%      contains flow data (i.e., not NaN or zero). For cases where the
%      blanking distance DOES exists, I have imposed a BC of U=0 at the bed,
%     -In cases where data goes all of the way to the bed, I have divided
%      the last bin's velocity by 2, essentially imposing a U=0 at the
%      boundary by extrapolating to the bottom of the bin.
%     -This function still needs to be incorporated into the GUI.

% V2 modifies the code for integration into the VMT GUI. Adds the Rozovskii output to
% the V structure and computes the X components of the primary and secondary 
% velocities (in addition to cross stream Y components). 
% P.R. Jackson, USGS


% Written by:
% Frank L. Engel (fengel2@illinois.edu)

% Last edited: 6/10/2010 FE
% FE- I fixed an error in computing theta for data in quadrants 3 & 4. The
%     linear interpolation of velocity to the bed BC was creating errors 
%     in the computation of us, so I removed it. Also, I made a new 
%     variable which is the sum of all vs as an error check (it should 
%     always sum to zero)

disp('Performing Rozovskii analysis...')
bin_size = double(A(1,1).Sup.binSize_cm)/100; % in meters

for i = 1:size(V.mcsMag,2)
    % Finds closest bin to beam avg. depth (ie from V.mcsBed)
    [min_difference(i), array_position(i)]...
        = min(abs(V.mcsDepth(:,i) - V.mcsBed(i)));
    %disp(['ap = ' num2str(array_position(i))])
    % Create a seperate version of the velocity data which can be modified,
    % preserving the VMT processing. Replaces all of the NaNs with u=0.
    temp_u = V.u; temp_v = V.v;
    n = find(isnan(V.u));
    temp_u(n) = 0; temp_v(n) = 0;
    
    % Compute Depth-averaged velocities and angles (using a difference
    % scheme)
    for j = 1:array_position(i)
        if j == 1 % Near water surface
            % Compute first bin by exprapolating velocity to the water
            % surface. WSE = 0. Imposes BC u(z=0) = u(z=bin1)
            du_i(j,i) = temp_u(j,i)*(V.mcsDepth(j+1,i)-V.mcsDepth(j,i))...
                + temp_u(j,i)*(V.mcsDepth(j,i)-bin_size/2-0);
            dv_i(j,i) = temp_v(j,i)*(V.mcsDepth(j+1,i)-V.mcsDepth(j,i))...
                + temp_v(j,i)*(V.mcsDepth(j,i)-bin_size/2-0);
        elseif j < array_position(i) % Inbetween
            du_i(j,i) = temp_u(j,i)*(V.mcsDepth(j+1,i)-V.mcsDepth(j-1,i))/2;
            dv_i(j,i) = temp_v(j,i)*(V.mcsDepth(j+1,i)-V.mcsDepth(j-1,i))/2;
            
            % Got rid of the linear interpolation to the bed- it was
            % messing up the Rozovskii secondary velocities (FE 6/10/2010)
        elseif j == array_position(i) % Near bed
            %             k=0;
            %             % Search bins above the bed for the first bin containing flow
            %             % data.
            %
            % %             while temp_u(j-k,i) == 0
            % %                 if temp_u(j-k,i) == 0; k = k + 1; else end % find next good bin
            % %             end
            %
            indx = find(temp_u(:,i) ~= 0);  %Revision PRJ 9-1-09
            if isempty(indx)
                du_i(:,i) = NaN;
                dv_i(:,i) = NaN;
            else
                l = indx(end);
                k = j - l;
                % Computes du from last good bin to the bed by linear
                % interpolation. IMPOSES BC: u=0 at the bed
%                 du_i(j-k+1,i) = (temp_u(j-k,i)-temp_u(j,i))/k...
%                     *(V.mcsDepth(j,i)-V.mcsDepth(j-k,i))/k;
%                 dv_i(j-k+1,i) = (temp_v(j-k,i)-temp_v(j,i))/k...
%                     *(V.mcsDepth(j,i)-V.mcsDepth(j-k,i))/k;
                
                % Paints everything below last bin as NaN
                du_i(j-k+2:size(V.u,2),i) = NaN;
                dv_i(j-k+2:size(V.u,2),i) = NaN;
            end
        end
    end
    
    % Depth averaged quantities
    U(i) = nansum(du_i(:,i))/V.mcsDepth(array_position(i),i);
    V1(i) = nansum(dv_i(:,i))/V.mcsDepth(array_position(i),i);
    U_mag(i) = sqrt(U(i)^2+V1(i)^2); % resultant vector
    
    % Angle of resultant vector from a perpendicular line along the
    % transect
    phi(i) = atan(V1(i)/U(i));
%     phi_deg(i) = rad2deg(phi(i));
    phi_deg(i) = (phi(i))*180/pi;
    
    % Compute Rozovskii variables at each bin
    for j = 1:array_position(i)
        u(j,i) = sqrt(V.u(j,i)^2+V.v(j,i)^2);
		if (V.u(j,i) < 0) && (V.v(j,i) < 0)
			theta(j,i) = atan(V.v(j,i)/V.u(j,i)) - pi();
		elseif (V.u(j,i) < 0) && (V.v(j,i) > 0)
			theta(j,i) = atan(V.v(j,i)/V.u(j,i)) + pi();
		else
			theta(j,i) = atan(V.v(j,i)/V.u(j,i));
		end
        theta_deg(j,i) = rad2deg(theta(j,i));
        up(j,i) = u(j,i)*cos(theta(j,i)-phi(i));
        us(j,i) = u(j,i)*sin(theta(j,i)-phi(i));
        upy(j,i) = up(j,i)*sin(phi(i));
        upx(j,i) = up(j,i)*cos(phi(i));
        usy(j,i) = us(j,i)*cos(phi(i));
        usx(j,i) = us(j,i)*sin(phi(i));
        depths(j,i) = V.mcsDepth(j,i);
        
        % Compute d_us to check for zero secondary discharge constraint
        if j == 1 % Near water surface
            dus_i(j,i) = us(j,i)*(V.mcsDepth(j+1,i)-V.mcsDepth(j,i))...
                + us(j,i)*(V.mcsDepth(j,i)-bin_size/2-0);
        elseif j < array_position(i) % Inbetween
            dus_i(j,i) = us(j,i)*(V.mcsDepth(j+1,i)-V.mcsDepth(j-1,i))/2;
        end
        % Sum dus_i - this should be near zero for each ensemble
        q_us(i) = nansum(dus_i(:,i));
    end
    
    % Resize variables to be the same as V structure array
    u(j+1:size(V.mcsMag,1),i) = NaN;
    theta(j+1:size(V.mcsMag,1),i) = NaN;
    theta_deg(j+1:size(V.mcsMag,1),i) = NaN;
    up(j+1:size(V.mcsMag,1),i) = NaN;
    us(j+1:size(V.mcsMag,1),i) = NaN;
    upy(j+1:size(V.mcsMag,1),i) = NaN;
    usy(j+1:size(V.mcsMag,1),i) = NaN;
    upx(j+1:size(V.mcsMag,1),i) = NaN;
    usx(j+1:size(V.mcsMag,1),i) = NaN;
    depths(j+1:size(V.mcsMag,1),i) = NaN;
    dus_i(j+1:size(V.mcsMag,1),i) = NaN;
end

% Display error message if rozovskii computation of q_us doesn't sum to
% zero
if q_us > 1e-4
    disp('Warning: Rozovskii secondary velocities not satisfying continuity!')
else
    disp('Computation successfull: Rozovskii secondary velocities satisfy continuity')
end

% Rotate local velocity vectors into global coordinate system by
% determining the angle of the transect using endpoint locations. The
% function "vrotation" is a standard rotation matrix
XStheta = atan((V.mcsY(1,end)-V.mcsY(1,1))/(V.mcsX(1,end)-V.mcsX(1,1)));
XSalpha = XStheta - pi/2;
[ux, uy, uz] = vrotation(V.u,V.v,V.w,XSalpha);

% Put results into the V structure

V.Roz.U = U;
V.Roz.V = V1;
V.Roz.U_mag  = U_mag;
V.Roz.phi = phi;
V.Roz.phi_deg = phi_deg;
V.Roz.u = V.u;
V.Roz.v = V.v;
V.Roz.u_mag = u;
V.Roz.depth = depths;
V.Roz.theta = theta;
V.Roz.theta_deg = theta_deg;
V.Roz.up = up;
V.Roz.us = us;
V.Roz.upy = upy;
V.Roz.usy = usy;
V.Roz.upx = upx;
V.Roz.usx = usx;
V.Roz.ux = ux;
V.Roz.uy = uy;
V.Roz.uz = uz;
V.Roz.alpha = XSalpha;

% Rozovskii = struct('Ux', {Ux}, 'Uy', {Uy}, 'U', {U}, 'phi', {phi},...
%     'phi_deg', {phi_deg},'ux', {V.u}, 'uy', {V.v}, 'u', {u}, 'depth', {depths},...
%     'theta', {theta}, 'theta_deg', {theta_deg}, 'up', {up}, 'us', {us},...
%     'upy', {upy}, 'usy', {usy});

% Name of output file needs to be modified to take handle args from GUI
% Save variable into the VMTProcFile folder
% outfolder = ['VMTProcFiles\'];
% outfile=['Rozovskii'];
% filename = [outfolder outfile];
% save(filename, 'Rozovskii');

disp('Rozovskii analysis complete. Added .Roz structure to V data structure.')
% directory = pwd;
% fileloc = [directory '\' filename '.mat'];
% disp(fileloc)
