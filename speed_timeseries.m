% Generate plot
addpath('/Users/jukesliu/Documents/MATLAB/cmocean_v2.0/cmocean'); % import cmocean
% addpath('/Users/jukesliu/Documents/MATLAB/mask2poly'); % import mask2poly

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % path to the centerline profile_ds1_ds2.csv files:
% cd_to_dir=['cd ''/Users/jukesliu/Documents/TURNER/data/velocity_maps/custom_autoRIFT_cline_data/filtered-north/''']; % CHANGE THIS
% eval(cd_to_dir); % go to directory
%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 
% %% Generate profiles
% filestruct = dir('/Users/jukesliu/Documents/TURNER/data/velocity_maps/centerline/');
% 
% % grab the good ones
% b = 1;
% gooddates = {};
% for a = 1:length(filestruct)
%     filename = filestruct(a).name;
%     if startsWith(filename, 'profile') && endsWith(filename, '.csv')
%         date = filename(9:end-4);
%         gooddates{b} = date;
%         b = b+1;
%     end
% end
% goodfiles = {};
% d = 1;
% matfiles = dir('/Users/jukesliu/Documents/TURNER/data/velocity_maps/');
% for c = 1:length(matfiles)
%     filename2 = matfiles(c).name;
%     if startsWith(filename2, 'offset') && endsWith(filename2, '.mat') % offset.mats 
%         filedate = filename2(11:27);
%         for f=1:length(gooddates)
%             if strcmp(gooddates{f},filedate) % if the dates are in good dates
%                 goodfiles{d} = filename2;
%                 d=d+1;
%             end
%         end
%     end
% end
% 
% goodfiles = dir('/Users/jukesliu/Documents/TURNER/data/velocity_maps/centerline_data_figure/');
% %generate the centerline
% for e = 1:length(goodfiles)
% %     cd ..
%     file = goodfiles(e);
%     if startsWith(file.name, 'profile') && ~endsWith(file.name,'S.csv')
%         disp(file.name)
%         centerlinespeed(file.name) % MODIFY THIS FOR SECOND CENTERLINE!!
%     end
%     eval(cd_to_dir); % go to back to centerline directory
% end
%%
% create_centerline(80, 'TG_centerline_L8_S.shp');
%% Stitch all profiles together:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% filestruct = dir('/Volumes/SURGE_DISK/VG/VG_centerline_velocities_sref/');
% cd_to_dir=['cd ''/Volumes/SURGE_DISK/VG/VG_centerline_velocities_sref/'''];
% filestruct = dir('/Users/jukesliu/Documents/TURNER/data/velocity_maps/ASF_autoRIFT/centerline-north/');
% cd_to_dir=['cd ''/Users/jukesliu/Documents/TURNER/data/velocity_maps/ASF_autoRIFT/centerline-north/''']; % CHANGE THIS
% filestruct = dir('/Users/jukesliu/Documents/TURNER/data/velocity_maps/centerline_data_figure/');
% cd_to_dir=['cd ''/Users/jukesliu/Documents/TURNER/data/velocity_maps/centerline_data_figure/''']; % CHANGE THIS

% SK paper figure:
% filestruct = dir('/Users/jukesliu/Documents/TURNER/data/velocity_maps/custom_autoRIFT_cline_data/filtered-north-new/');
% cd_to_dir=['cd ''/Users/jukesliu/Documents/TURNER/data/velocity_maps/custom_autoRIFT_cline_data/filtered-north-new/'''];
filestruct = dir('/Volumes/JUKES_EXT/CautoRIFT_sites/SK_centerline_velocities/filtered/');
cd_to_dir=['cd ''/Volumes/JUKES_EXT/CautoRIFT_sites/SK_centerline_velocities/filtered/'''];
eval(cd_to_dir); % go to directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% grab the number of spacings
counter = 0;
for a = 1:length(filestruct)
    filename = filestruct(a).name;
%     if startsWith(filename, 'profile') && endsWith(filename, '_S.csv') %
%     Southern tributary
%     if startsWith(filename, 'profile') && ~endsWith(filename, 'S.csv')
    if endsWith(filename, '.csv') %&& ~endsWith(filename,'old.csv')
        counter = counter+1;
    end
end
Y = cell(counter*2,1);

% grab the dates and values
idx = 1;
speed_mat = zeros(counter*2,121); % CHANGE VALUE to 121 or 98 or 72
for b = 1:length(filestruct)
    filename = filestruct(b).name;
%     if startsWith(filename, 'profile') && endsWith(filename, 'S.csv')
%     if startsWith(filename, 'profile') && endsWith(filename, '.csv') && length(filename) == 29
    if endsWith(filename, '.csv') && ~endsWith(filename,'old.csv')
%         ds1 = filename(9:16);
%         ds2 = filename(18:25);
        ds1 = filename(1:8); % the first date string
        ds2 = filename(10:17); % the second date string
        sat = filename(19:20);
%         dy = years(datetime(ds2, 'InputFormat','yyyyMMdd') - datetime(ds1, 'InputFormat', 'yyyyMMdd'));
        
        % read in the table
        T = readtable(filename);
        speed_prof = table2array(T(:,3)); % third column has the speeds
        dist = table2array(T(:,2)); % 2nd column contains the distances   
        if max(dist) > 100 % if not yet converted to km
            km = dist/1000;
        else 
            km = dist; % otherwise leave alone
        end

        if length(speed_prof) ~=121 % CHANGE VALUE to 121 (SK) or 98 (SK) or 72 (VG)
            disp(filename)
        end

%         if sat == 'S2'
%             speed_prof = speed_prof/365; % convert
%         end
        
%         % if L8, must interpolate:
%         if length(speed_prof) ~= 97
%             speed_prof = interp1(linspace(1,97,length(speed_prof)), speed_prof, 1:97,...
%                 'Linear','extrap');
%         end

        speed_mat(idx,:) = speed_prof;


        if ~isempty(Y{idx}) % if there is something in the cell already,
            % it's the previous ds2. If continuous record, they should be equal.
            if ~strcmp(Y{idx}, ds1) % if they are not equal,
                % do not replace, add to the next index.
                idx = idx+1;
            end
        end
        Y{idx}=ds1; Y{idx+1}=ds2;
        idx = idx+1;
    end
end

% grab final Y divisions and convert to dates
n = 1;
for j=1:length(Y)
    if isempty(Y{n}) == 0 % if not empty
        n=n+1; % count it
    else
        break % stop
    end
end
    
Ydiv = Y(1:n-1)
% CONVERT TO DATES
Ys = datetime(Ydiv, 'InputFormat','yyyyMMdd');

%filter out overlaps:
Ys(diff(Ys) <= 0) % should be empty! Delete those that appear here

%% grab final speed_mat
speed_mat = speed_mat(1:n-1,:);

% visualize
clf;
% imagesc(fliplr(speed_mat)); 
imagesc(speed_mat); % for VG
%cmocean('-curl'); 
cmocean('thermal')
colorbar; 
caxis([0 30*365]);
set(gca,'Xdir','reverse'); 
%% resample grid
% set the spacing factor:
spacing = round(diff(Ys)/min(diff(Ys)));

% Define the new Y:
Y_spaced = Ys(1):min(diff(Ys)):Ys(end);

% spacing the data:
speed_spaced = repelem(speed_mat,spacing([1 1:end]),1); % VELOCITY
speed_spaced(speed_spaced == 0) = NaN;
speed_spaced = speed_spaced(1:end-10,:); % leave off last empty column(s)
speed_spaced = speed_spaced/365; % convert to m/d

% % % % grab a subset!
% % FIRST HALF
% speed_spaced = speed_spaced(1:1350, :); % ONLY PART OF THE ARRAY
% Y_spaced = Y_spaced(1:1350);
% % SECOND HALF
% speed_spaced = speed_spaced(580:end, :); % ONLY PART OF THE ARRAY
% Y_spaced = Y_spaced(580:end);

% % % 2020-2021
% speed_spaced = speed_spaced(2510:end, :); % ONLY PART OF THE ARRAY
% Y_spaced = Y_spaced(2510:end);
% % add some rows
% speed_spaced = cat(1, speed_spaced, NaN(60,121)); % add zeros

% make Nans black using alpha data
imAlpha=ones(size(speed_spaced));
imAlpha(isnan(speed_spaced))=0;

% set(gcf,'Position',[0 500 650 800]); clf;
% set(gcf,'Position',[0 500 500 1000]); clf;
set(gcf,'Position',[0 500 600 800]); clf;
% imagesc(fliplr(speed_spaced),'AlphaData',imAlpha); 
imagesc(speed_spaced,'AlphaData',imAlpha); 
% cmocean('-curl'); 
% caxis([-100 100]); % COLORBAR
cmocean('thermal'); 
% set(gca,'Xdir','reverse');
set(gca,'FontSize',14,'TickDir','out'); 
h = colorbar; h.FontSize = 14; %h.Limits = [0 35]; % colorbar
% set(get(h,'label'),'string','Surface speed [m/d]'); 
set(get(h,'label'),'string','Surface speed [m/d]'); % colorbar label
h.TickDirection = 'out';
% caxis([0 30]);
% set(gca,'ColorScale','log'); 
caxis([0 25]);
% caxis([0.02 1]);
% % % caxis([1 30]);
% caxis([0 25]); % log colorbar and limits

% XTICK LABELS
km_tot = round(max(km)); % total length of centerline (km)
km_spacing = 2; % tick mark every # kilometers
set(gca,'XTick',0:size(speed_spaced,2)/km_tot*km_spacing:size(speed_spaced,2));
km_labels = 0:km_spacing:km_tot;
xticklabels(fliplr(km_labels));
xlabel('Distance from terminus (km)');
set(gca,'color',0*[1 1 1]); % background color = black

% % XTICK LABELS: VARIEGATED
% km_tot = round(max(km)); % total length of centerline (km)
% km_spacing = 2; % tick mark every # kilometers
% set(gca,'XTick',1:size(speed_spaced,2)/(km_tot)*km_spacing:size(speed_spaced,2));
% km_labels = 0:km_spacing:km_tot;
% xticklabels(km_labels);
% xlabel('Distance from terminus (km)');
% set(gca,'color',0*[1 1 1]); % background color = black

% ANNUAL YTICKS
yrs_tot = years(Y_spaced(end) - Y_spaced(1));
% yr_ticks = [(yrs_tot-round(yrs_tot))-1 (yrs_tot-round(yrs_tot)):1:yrs_tot+1]; % annual ticks
min_dt =  years(min(diff(Ys))); % in years
set(gca,'YTick',280:(1/min_dt)*1.01:size(speed_spaced,1)); % annual ticks - North
% set(gca,'YTick',1:(1/min_dt)*1.0:size(speed_spaced,1)); % annual ticks - North
% set(gca,'YTick',100:(1/min_dt)*1.01:size(speed_spaced,1)); % North - 2017 onwards
% set(gca,'YTick',275:(1/min_dt)*1.01:size(speed_spaced,1)); % North - 2013-2017
% set(gca,'YTick',-349:350:size(speed_spaced,1)); % VG
% yticklabels([2021, 2022])
% yticklabels(['2021-01'; '2021-03'; '2021-06';'2021-09'; '2022-01';'2022-03'])
yticklabels([2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024]);
% yticklabels([2018, 2019, 2020, 2021, 2022]);
% yticklabels([1980,1999, 2004, 2009, 2014, 2019]);
% yticklabels([2017, 2018, 2019, 2020, 2021, 2022]);
% yticklabels([2014, 2015, 2016, 2017]);

% set(gca,'YTick',1:(1/min_dt)/2:size(speed_spaced,1)); % annual ticks - North
% yticklabels(['2020-01'; '2020-07'; '2021-01'; '2021-07';'2022-01']);

% set(gca,'YTick',-30*5.3:365:length(speed_spaced)+96); % yearly, 2013-2021
% ydates = [Y_spaced(1)-30*5.3:366:Y_spaced(end)+96]; % yearly, 2013-2021
% ydates = [Y_spaced(1)-30*5.3:366*2:Y_spaced(end)+96]; % biyearly, 2013-2021
% yticklabels(datestr(ydates,'yyyy'));

% set(gca,'YTick',-30*2.5:365/2:1000); % 6 months, 2019-2021
% % set(gca,'YTick',-30*3:365/4:1000); % 3 months
% set(gca,'YTick',Y_spaced); % 3 months
% ydates = [Y_spaced(1)-34, Y_spaced(1)+58:183:Y_spaced(end),Y_spaced(end)]; % July 1 : :Oct 1
% ydates = [Y_spaced(1)-, Y_spaced(1)-30*3.5:92*2:Y_spaced(end)+96]; 
% ydates = linspace(Y_spaced(1)-, Y_spaced(end)-96, 6);
% ydates = [2019.5,2020.0,2020.5,2021.0,2021.5];
% ydates = [2020.0,2021.0,2021.25,2021.50,2021.75];
% datetick('y','yyyy')
% yticklabels(datestr(Y_spaced(5:5:end), 'mmm yyyy'));


% %% FUNCTIONS:
% 
% function centerlinespeed(filename)
% % Function to extract speeds along the drawn centerline for a specified
% % file. Automatically saves the profile to a .csv and plots a figure.
% % INPUTS: filename for the .mat file produced from autoRIFT. OUTPUTS:
% % table containing the centerline distance (km) from the start in one
% % column and the speed in the second column.
% % SYNTAX: centerlinespeed(filename)
% 
% S = load(filename); % load the file
% % platform = filename(8:9); % the platform ID
% ds1 = filename(9:16); % the first date string
% ds2 = filename(18:25); % the second date string
% % disp(platform);
% 
% % use image dates to get date offset
% date1 = datetime(ds1,'InputFormat','yyyyMMdd');
% date2 = datetime(ds2,'InputFormat','yyyyMMdd');
% day1 = daysact(date1); day2 = daysact(date2); 
% dt = day2 - day1
% 
% % confirm sentinel-2 or Landsat 8 platform
% if platform == 'S2'
%     pixres = 10;
%     shpstring = 'TG_centerline_S2_S.shp'; % filename for centerline
%     outlinestring = 'TG_outline_S2.mat'; % filename for outline
% elseif platform == 'L8'
%     pixres = 15;
%     shpstring = 'TG_centerline_L8.shp'; % filename for centerline - just use the same as S2
%     outlinestring = 'TG_outline_L8.mat'; % filename for outline
% elseif platform == 'PL'
%     pixres = 3;
%     shpstring = 'TG_centerline_S2_S.shp';
%     outlinestring = 'TG_outline_PL.shp';
% else
%     disp('Image platform not recognized. Enter pixel resolution manually.')
% end
% 
% % Generate flow orientation and speed maps
% % divide displacement by time to get velocities
% Vx = S.Dx./dt;
% Vy = S.Dy./dt;
% % calculate flow direction (deg) and speed from velocities
% flowdir = atan2(Vy, Vx)*(180/pi); 
% speed = sqrt((Vy.^2) + (Vx.^2));
% 
% % Plot speeds along centerline
% speed_md = speed.*pixres; % grid of flow speeds in m/d
% 
% if ~isfile(shpstring) % if the file hasn't already been made
%     disp('Trace centerline.'); % draw the profile to extract velocities along
%     create_centerline(100, shpstring); % user generates centerline
% else % if it has, just pull the coordinates from the shapefile
%     Cline = shaperead(num2str(shpstring));
%     flowline.X = Cline.X; flowline.Y = Cline.Y; 
% end
% 
% flowline_x = uint8(flowline.X); flowline_y = uint8(flowline.Y); % convert to integers
% % pull the speeds along the centerline
% speed_prof = zeros(1,length(flowline_x));
% disp(flowline_x);
% disp(size(speed_md));
% for i = 1:length(flowline_x)
%     x = flowline_x(i); y = flowline_y(i); % grab the index
%     if x > 0 && y > 0
%         speed_prof(i) = speed_md(y,x); % store the speed value
%     end
% end
% 
% % writematrix([[(1:length(speed_prof)).*240/1000]', speed_prof'],...
% %     ['profile_',ds1,'_',ds2,'_S.csv']) % Write the profile (km) to a CSV file
% 
% plot((1:length(speed_prof))*240/1000, speed_prof, '-', 'Linewidth',3); % plot along converted pixels --> km
% set(gca,'FontSize',20); ylim([0 max(speed_prof)+1]); ylabel('Surface speed (m/d)'); grid on
% xlabel('km along centerline');
% 
% end
% 
% 
% %%
% function create_glacier_outline(outlinestring)
% disp('Trace around glacier bounds.');
% glacieroutline = roipoly; % user drawn input
% glacieroutline = double(glacieroutline); % convert to double 
% save(num2str(outlinestring),'glacieroutline'); % save the mask
% end
% 
% %%
% function create_centerline(spacer, shpstring)
% % Function to take user drawn centerline and interpolate regularly
% % at the defined spacing increment.
% % INPUTS:
% %       - spacing: interpolation spacing (units?)
% %       - shpstring: the desired name of the output shapefile
% % OUTPUTS:
% %       - creates the flowline struct and writes to shapefile
% %       - distvals: distance values along the centerline drawn
% 
% [xi,yi,~] = improfile;
% 
% %create a regularly interpolated version of the centerline
% profx_points = []; profy_points = [];
% if max(xi)-min(xi) > max(yi) - min(yi)
%     profy = fit(xi,yi,'smoothingspline'); %longer in x-direction so spline works better w/ x as the independent variable
%     for k = 2:length(xi)
%         center_orient = atand((yi(k)-yi(k-1))./(xi(k)-xi(k-1)));
%         profx_points = [profx_points; [xi(k-1):sign(xi(k)-xi(k-1))*abs(spacer*sind(center_orient)):xi(k)]'];
%         profy_points = [profy_points; profy(xi(k-1):sign(xi(k)-xi(k-1))*abs(spacer*sind(center_orient)):xi(k))];
%         clear center_orient;
%     end
%     clear profy;
% else
%     profx = fit(yi,xi,'smoothingspline'); %longer in y-direction so spline works better w/ y as the independent variable
%     for k = 2:length(xi)
%         center_orient = atand((yi(k)-yi(k-1))./(xi(k)-xi(k-1)));
%         profy_points = [profy_points; [yi(k-1):sign(yi(k)-yi(k-1))*abs(spacer*cosd(center_orient)):yi(k)]'];
%         profx_points = [profx_points; profx(yi(k-1):sign(yi(k)-yi(k-1))*abs(spacer*cosd(center_orient)):yi(k))];
%         clear center_orient;
%     end
%     clear profx;
% end
% clear xi yi;
% 
% % add the profile to a structure & export a shapefile
% flowline.X = profx_points'; flowline.Y = profy_points';
% %convert the centerline coordinates to along-profile distance from the origin
% flowline.centerline(1) = 0;
% for k = 2:length(flowline.X)
%     flowline.centerline(k) = flowline.centerline(k-1)+sqrt((flowline.X(k)-flowline.X(k-1)).^2 + (flowline.Y(k)-flowline.Y(k-1)).^2);
% end
% 
% % save flowline struct
% % distvals = flowline.centerline; 
% flowline.Geometry = 'Polyline' ; flowline.Name = 'North_branch_flowline' ;
% flowline = rmfield(flowline,'centerline'); % remove centerline struct
% shapewrite(flowline, num2str(shpstring));
% end
