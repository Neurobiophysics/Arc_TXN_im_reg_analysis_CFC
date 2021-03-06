function circleFinderFigHndl = circleFinder(inputImage, radiusRange)
% Detect and mark circles in an image using an interactive UI
%
% SYNTAX:
%
% circleFinder
%    Launches the Circle Finder app with the default image
%    ('coins.png') pre-loaded.
%
% circleFinder(inputImage)
%    Allows user to specify input image, or the name of an input image.
%
% circleFinder(..., radiusRange)
%    Allows user to specify radius range as [minRadius maxRadius]
%
% (Note that OUTPUTS are supported via an "EXPORT" button.)
%
% NOTE ON DEPENDENCIES:
%    A dependency analysis will indicate that the Computer Vision System
%    Toolbox is required. I use functionality in that Toolbox (in
%    export function) IF it is on the user license. It is NOT OTHERWISE
%    REQUIRED!
%
% CLASS SUPPORT:
%    inputImage can be any valid image format readable by
%    IMREAD. Color (RGB) images are supported, but circle
%    detection is performed on the RGB2GRAY representation.
%    (See help for IMFINDCIRCLES for details.)
%
% Written by Brett Shoelson, PhD
% brett.shoelson@mathworks.com
% Comments and suggestions welcome!
%
% See Also: IMFINDCIRCLES, VISCIRCLES

% Copyright The MathWorks, Inc. 2015.
% V 2.0; 11/20/2014
%     Modified from, and as a replacement for, FindCirclesGUI; 
%     Verified R2014b compliance. Removed checkbox activation of
%     EdgeThreshSlider. (I didn't like it, don't think it was necessary.)
%     Reformatted code. Exports function handle. Also incorporates
%     createCirclesMask (pending approval as MLL).
% V 2.1; 2/5/15
%     Made singleton

 if verLessThan('images', '8.0')
     beep
     disp('SORRY! circleFinder requires Image Processing Toolbox Ver. 8.0 (MATLAB R2012a) or later!');
     %return
 end

if nargin < 1 || isempty(inputImage)
    fname = 'coins.png';
    inputImage = imread('coins.png');
elseif ischar(inputImage)
    fname = inputImage;
    inputImage = imread(inputImage);
else
    fname = 'Original';
end

if nargin < 2
    minRadius = 20;
    maxRadius = 30;
else
    minRadius = radiusRange(1);
    maxRadius = radiusRange(2);
end

bgc = [0.55 0.65 0.65];
tbc = 240/255; %toolbar color, approximately
%
singleton = true;
if singleton && ~isempty(findall(0,'name','circleFinder'))
	delete(findall(0,'name','circleFinder')); %Singleton
end
%
circleFinderFig = figure(...
    'numbertitle', 'off', ...
    'windowstyle', 'normal', ...
    'name', 'circleFinder', ...
    'units', 'Normalized', ...
    'Position', [0.1875 0.05 0.625 0.85], ...
    'color', bgc, ...
    'tag', 'circleFinderFig', ...
	'menubar', 'none');
circleFinderFigHndl = circleFinderFig;

ht = uitoolbar(circleFinderFig);
tmp = im2double(imread('file_open.png'));
tmp(tmp==0) = NaN;
loadImageTool = uitoggletool(ht, ...
    'CData', tmp, ...
    'oncallback', @GetNewFile, ...
    'offcallback', '', ...
    'Tooltipstring', 'Load new image', ...
    'Tag', 'loadImageTool'); %#ok<*NASGU>

tmp = im2double(imread('tool_zoom_in.png'));
tmp(tmp==0) = NaN;
zoomTool = uitoggletool(ht, ...
    'CData', tmp, ...
    'oncallback', @toggleZoom, ...'zoom;set(gcbo, ''state'', ''off'')', ...
    'offcallback', '', ...
    'Tooltipstring', 'Toggle zoom state');

tmp = imread('distance_tool.gif');
tmp = label2rgb(tmp, tbc*ones(3), [0 0 0]);
distanceTool = uitoggletool(ht, ...
    'CData', tmp, ...
    'oncallback', 'imdistline;set(gcbo, ''state'', ''off'')', ...
    'offcallback', '', ...
    'Tooltipstring', 'Add IMDISTLINE Tool');

tmp = imcomplement(tmp);
delDistanceTool = uitoggletool(ht, ...
    'CData', tmp, ...
    'oncallback', @clearDistlineTools, ...
    'offcallback', '', ...
    'Tooltipstring', 'Clear IMDISTLINE Tool(s)');

tmp = ones(11);
tmp([1:3, 9:13, 21:23, 33, 89, 99:101, 109:113, 119:121]) = 0;
tmp(6, :) = 0;tmp(:, 6) = 0;
tmp2 = label2rgb(tmp, tbc*ones(3), [0 0 1]);
markObjectsTool = uitoggletool(ht, ...
    'CData', tmp2, ...
    'oncallback', @markPoints, ...
    'offcallback', '', ...
    'Tooltipstring', 'Manually count objects');

tmp2 = label2rgb(~tmp, tbc*ones(3), [0 0 1]);
markObjectsTool = uitoggletool(ht, ...
    'CData', tmp2, ...
    'oncallback', @clearMarkedPoints, ...
    'offcallback', '', ...
    'Tooltipstring', 'Clear counting marks');

tmp = imread('DefaultD.png');
defaultButton = uitoggletool(ht, ...
    'CData', tmp, ...
    'separator', 'on', ...
    'oncallback', @resetDefaults, ...
    'Tooltipstring', 'Resets all uicontrols/parameters to defaults.');

tmp = imread('logo.png');
infoButton = uitoggletool(ht, ...
    'CData', tmp, ...
    'separator', 'on', ...
    'oncallback', @acknowledge, ...
    'Tooltipstring', 'Acknowledgements');
dfs = 8;
set(circleFinderFig, ...
    'defaultuicontrolunits', 'Normalized', ...
    'defaultuicontrolbackgroundcolor', bgc, ...
    'defaultuicontrolfontsize', dfs);

ImageAxis = axes(...
    'Parent', circleFinderFig, ...
    'Units', 'Normalized', ...
    'Position', [0.05 0.35 0.9 0.6 ], ...
    'Color', bgc, ...
    'Tag', 'ImageAxis', ...
    'XLimMode', 'auto', ...
    'YLimMode', 'auto', ...
    'Visible', 'off');

ImgObj = imshow(inputImage, 'parent', ImageAxis);
ImgTitle = title(fname, 'interpreter', 'none');
expandAxes(ImageAxis);

[objpos, objdim] = distributeObjects(4, 0.025, 0.975, 0.025);

CommentsPanel = uipanel(...
    'Parent', circleFinderFig, ...
    'Title', 'Comments/Status', ...
    'Tag', 'CommentsPanel', ...
    'Units', 'Normalized', ...
    'Position', [objpos(1) 0.03 0.975-objpos(1) 0.05]);

CommentsBox = uicontrol(...
    'Parent', CommentsPanel, ...
    'Style', 'Edit', ...
    'String', 'Welcome to Circle Finder! ? 2014 The MathWorks, Inc.', ...
    'Tag', 'CommentsBox', ...
    'Units', 'Normalized', ...
    'Fontsize', dfs+2, ...
    'Position', [0 -0.01 1 1.06], ...
    'Enable', 'Inactive');

SensitivityPanel = uipanel(...
    'Parent', circleFinderFig, ...
    'Title', 'Sensitivity', ...
    'Tag', 'SensitivityPanel', ...
    'Units', 'Normalized', ...
    'Position', [objpos(1) 0.0925 objdim 0.125]);

[SensitivitySlider, ~, SensitivityEdt] = sliderPanel(...
    'Parent', SensitivityPanel, ...
    'Title', '', ...
    'Position', [0.05 0.05 0.9 0.9], ...
    'Backgroundcolor', bgc, ...
    'Min', 0, ...
    'Max', 1, ...
    'Value', 0.85, ...
    'NumFormat', '%0.2f', ...
    'Callback', @processCircleFinder);
set(findobj(SensitivityPanel, 'style', 'slider'), ...
    'TooltipString', ...
    sprintf('A high sensitivity value leads to detecting more\ncircles, including weak or partially obscured ones at\nthe risk of a higher false detection rate.\nDefault value: 0.85.'));

EdgeThresholdPanel = uipanel(...
    'Parent', circleFinderFig, ...
    'Title', 'Edge Threshold', ...
    'Tag', 'EdgeThresholdPanel', ...
    'Units', 'Normalized', ...
    'Position', [objpos(2) 0.0925 objdim 0.125]);

[EdgeThresholdSlider, ~, EdgeThresholdEdt] = sliderPanel(...
    'Parent', EdgeThresholdPanel, ...
    'Title', '', ...
    'Position', [0.05 0.05 0.9 0.9], ...
    'Backgroundcolor', bgc, ...
    'Min', 0, ...
    'Max', 1, ...
    'Value', 0.3, ...
    'NumFormat', '%0.2f', ...
    'Callback', @processCircleFinder);
EdgeSlider = findobj(EdgeThresholdSlider, 'style', 'slider');

VisualizationPanel = uipanel(...
    'Parent', circleFinderFig, ...
    'Title', 'Visualization Options', ...
    'Tag', 'VisualizationPanel', ...
    'Position', [objpos(3) 0.0925 objdim*1.3 0.125]);

LineWidthText = uicontrol(...
    'Parent', VisualizationPanel, ...
    'Callback', '', ...
    'Units', 'Normalized', ...
    'Position', [0.05 0.525 0.35 0.4], ...
    'String', 'Line Width', ...
    'Style', 'text', ...
    'HorizontalAlignment', 'Left', ...
    'Tag', 'LineWidthText');

lineWidthVal = 2;
LineWidthValBox =  uicontrol(...
    'Parent', VisualizationPanel, ...
    'Callback', @processCircleFinder, ...
    'Units', 'Normalized', ...
    'Position', [0.4 0.55 0.2 0.4], ...
    'String', [0.5;1.0;1.5;2.0;3.0;4.0;8.0], ...
    'Style', 'popupmenu', ...
    'Value', lineWidthVal, ...
    'Fontsize', dfs+1, ...
    'Tag', 'LineWidthValBox');

LineStyleText = uicontrol(...
    'Parent', VisualizationPanel, ...
    'Callback', '', ...
    'Units', 'Normalized', ...
    'Position', [0.05 0.225 0.35 0.4], ...
    'String', 'Line Style', ...
    'Style', 'text', ...
    'HorizontalAlignment', 'Left', ...
    'Tag', 'LineStyleText');

LineStyleValBox =  uicontrol(...
    'Parent', VisualizationPanel, ...
    'Callback', @processCircleFinder, ...
    'Units', 'Normalized', ...
    'Position', [0.4 0.25 0.2 0.4], ...
    'String', {'-', '--', '-.', ':'}, ...
    'Style', 'popupmenu', ...
    'Value', 2, ...
    'Fontsize', dfs+1, ...
    'Tag', 'LineStyleValBox');

circleColor = [0 1 1];
circleColorButton = uicontrol(...
    'Parent', VisualizationPanel, ...
    'style', 'pushbutton', ...
    'Position', [0.7 0.45 0.15 0.45], ...
    'cdata', reshape(kron(circleColor, ones(25, 25)), 25, 25, 3), ...
    'callback', @changeCircleColor, ...
	'tooltipstring','Change color of detected circles.',...
    'tag', 'circleColorButton');
setappdata(circleColorButton, 'circleColor', circleColor);

ClearPrevious = uicontrol(...
    'Parent', VisualizationPanel, ...
    'Callback', '', ...
    'Units', 'Normalized', ...
    'Position', [0.05 0.025 0.45 0.2], ...
    'String', 'Clear previous circles', ...
    'Style', 'checkbox', ...
    'Value', 1, ...
	'Fontsize', 7, ...
    'Tag', 'ClearPrevious');

UseWhiteBG = uicontrol(...
    'Parent', VisualizationPanel, ...
    'Callback', @processCircleFinder, ...
    'Units', 'Normalized', ...
    'Position', [0.55 0.025 0.45 0.2], ...
    'String', 'White Background', ...
    'Style', 'checkbox', ...
    'Value', 0, ...
	'Fontsize', 7, ...
    'Tag', 'UseWhiteBG');

ObjectPolarityPanel = uibuttongroup(...
    'Parent', circleFinderFig, ...
    'Title', 'Object Polarity', ...
    'Tag', 'ObjectPolarityPanel', ...
    'Units', 'Normalized', ...
    'Position', [objpos(1) 0.2275 objdim 0.0625], ...
    'SelectedObject', [], ...
    'SelectionChangeFcn', @processCircleFinder, ...
    'OldSelectedObject', []);

BrightButton = uicontrol(...
    'Parent', ObjectPolarityPanel, ...
    'Units', 'Normalized', ...
    'Position', [0.05 0.25 0.425 0.5], ...
    'String', 'Bright', ...
    'Style', 'radiobutton', ...
    'TooltipString', 'Circles are brighter than the background.', ...
    'Value', 1, ...
    'Tag', 'Bright');

DarkButton = uicontrol(...
    'Parent', ObjectPolarityPanel, ...
    'Units', 'Normalized', ...
    'Position', [0.50 0.25 0.425 0.5], ...
    'String', 'Dark', ...
    'Style', 'radiobutton', ...
    'TooltipString', 'Circles are darker than the background.', ...
    'Tag', 'Dark');

MethodPanel = uibuttongroup(...
    'Parent', circleFinderFig, ...
    'Title', 'Method', ...
    'Tag', 'MethodPanel', ...
    'Units', 'Normalized', ...
    'Position', [objpos(2) 0.2275 objdim 0.0625], ...
    'SelectedObject', [], ...
    'SelectionChangeFcn', @processCircleFinder, ...
    'OldSelectedObject', []);

PhaseCodeButton = uicontrol(...
    'Parent', MethodPanel, ...
    'Units', 'Normalized', ...
    'Position', [0.05 0.25 0.425 0.5], ...
    'String', 'Phase Code', ...
    'Style', 'radiobutton', ...
    'Value', 1, ...
    'Tag', 'PhaseCode', ...
    'Tooltipstring', ...
    sprintf('Specifies use of Atherton and Kerbyson''s Phase Coding method\nfor computing the accumulator array. (This is the Default.)'));

TwoStageButton = uicontrol(...
    'Parent', MethodPanel, ...
    'Units', 'Normalized', ...
    'Position', [0.5 0.25 0.425 0.5], ...
    'String', 'Two-Stage', ...
    'Style', 'radiobutton', ...
    'Tag', 'TwoStage', ...
    'Tooltipstring', ...
    sprintf('Specifies use of the Two-stage Circular Hough Transform method\nfor computing the accumulator array.'));

ProcessOptionsPanel = uibuttongroup(...
    'Parent', circleFinderFig, ...
    'Title', 'Process Options', ...
    'Tag', 'ProcessOptionsPanel', ...
    'Units', 'Normalized', ...
    'Position', [0.8 0.0925 0.175 0.125], ...
    'SelectedObject', [], ...
    'SelectionChangeFcn', @processCircleFinder, ...
    'OldSelectedObject', []);

ProcessButton = uicontrol(...
    'Parent', ProcessOptionsPanel, ...
    'Callback', @processCircleFinder, ...
    'FontSize', dfs, ...
    'Units', 'Normalized', ...
    'Position', [0.05 0.4 0.9 0.3], ...
    'String', 'Process Now', ...
    'Tag', 'ProcessButton');

ExportButton = uicontrol(...
    'Parent', ProcessOptionsPanel, ...
    'Callback', @exportResults, ...
    'FontSize', dfs, ...
    'Units', 'Normalized', ...
    'Position', [0.05 0.05 0.9 0.3], ...
    'String', 'Export/Save Results', ...
    'Tag', 'ExportButton');

ProcessImmediatelyBox = uicontrol(...
    'Parent', ProcessOptionsPanel, ...
    'Callback', '', ...
    'Units', 'Normalized', ...
    'Position', [0.05 0.8 0.9 0.15], ...
    'String', 'Process Immediately', ...
    'Style', 'checkbox', ...
    'Value', 0, ...
    'Tag', 'ProcessImmediatelyBox');

RadiusRangePanel = uipanel(...
    'Parent', circleFinderFig, ...
    'Title', 'Radius Range', ...
    'Tag', 'RadiusRangePanel', ...
    'Units', 'Normalized', ...
    'Position', [objpos(3) 0.2275 1-objpos(3)-objpos(1) 0.0625]);

MinRadiusText = uicontrol(...
    'Parent', RadiusRangePanel, ...
    'Style', 'text', ...
    'Units', 'Normalized', ...
    'Position', [0.175 0.25 0.3 0.5], ...
    'String', 'Minimum Radius', ...
    'HorizontalAlignment', 'Left', ...
    'Tag', 'MinRadiusText');

MaximumRadiusText = uicontrol(...
    'Parent', RadiusRangePanel, ...
    'Style', 'text', ...
    'Units', 'Normalized', ...
    'Position', [0.675 0.25 0.3 0.5], ...
    'String', 'Maximum Radius', ...
    'HorizontalAlignment', 'Left', ...
    'Tag', 'MaximumRadiusText');

MinRadiusBox = uicontrol(...
    'Parent', RadiusRangePanel, ...
    'BackgroundColor', [1 1 1], ...
    'Callback', @processCircleFinder, ...
    'FontSize', dfs, ...
    'Units', 'Normalized', ...
    'Position', [0.05 0.15 0.1 0.6], ...
    'String', minRadius, ...%'20', ...
    'Style', 'edit', ...
    'Tag', 'MinRadiusBox');

MaxRadiusBox = uicontrol(...
    'Parent', RadiusRangePanel, ...
    'Units', 'Normalized', ...
    'BackgroundColor', [1 1 1], ...
    'Callback', @processCircleFinder, ...
    'FontSize', dfs, ...
    'Position', [0.525 0.15 0.1 0.6], ...
    'String', maxRadius, ...%'30', ...
    'Style', 'edit', ...
    'Tag', 'MaxRadiusBox');
bgsAndPanels = [findobj(circleFinderFig, 'type', 'uibuttongroup');
	findobj(circleFinderFig, 'type', 'uipanel')];
set(bgsAndPanels, ...
    'Units', 'Normalized', ...
    'BorderType', 'etchedin', ...
    'FontSize', 8, ...
    'ForegroundColor', [0 0 0], ...
    'TitlePosition', 'lefttop', ...
    'backgroundColor', bgc)
set(circleFinderFig, 'Handlevisibility', 'callback');

if ~nargout
    clear circleFinderFigHndl
end
%%% SUBFUNCTIONS

    function acknowledge(varargin)
        mssg = {'', ...
            '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ', ...
            '', ...
            'I would like to acknowledge and thank the following for', ...
            'suggestions, reviews, and critiques of this tool:', ...
            '', ...
            'Jiro Doke', ...
            'Simone Haemmerle', ...
            'Steve Kuznicki', ...
            'Grant Martin', ...
            'Jeff Mather', ...
            'Alex Taylor', ...
            'Spandan Tiwari', ...
            'Ashish Uthama', ...
            'The Image Processing Toolbox Development Team', ...
            '', ...
            'Comments and suggestions are welcome, ', ...
            'and should be addressed to me at:', ...
            '', ...
            'brett.shoelson@mathworks.com', ...
            '', ...
            '? 2012 MathWorks, Inc.', ...
            '', ...
            '', ...
            '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ', ...
            ''};
        h = msgbox(mssg, 'ImageRegistrationGUI Acknowledgments', 'help', 'modal') ;
        msghndl = findobj(h, 'tag', 'MessageBox');
        set(msghndl, 'color', [0 0 0.7], 'fontweight', 'b', 'fontname', 'helvetica')
        set(gcbo, 'state', 'off')
    end


    function changeCircleColor(varargin)%circleColor =
        circleColor = getappdata(circleColorButton, 'circleColor');
        circleColor = uisetcolor(circleColor);
        set(circleColorButton, 'cdata', reshape(kron(circleColor, ones(25, 25)), 25, 25, 3));
        setappdata(circleColorButton, 'circleColor', circleColor);
        processCircleFinder(gcbo)
    end

    function myhandle = circles(radii, centers, lineWidthVal, lineStyleVal, circColor)
        % Plots multiple circles as a single line object
        % Written by Brett Shoelson, PhD
        resolution = 2;
        theta=0:resolution:360;
        
        x_circle = bsxfun(@times, radii, cos(theta*pi/180));
        x_circle = bsxfun(@plus, x_circle, centers(:, 1));
        x_circle = cat(2, x_circle, nan(size(x_circle, 1), 1));
        x_circle =  x_circle';
        x_circle = x_circle(:);
        
        y_circle = bsxfun(@times, radii, sin(theta*pi/180));
        y_circle = bsxfun(@plus, y_circle, centers(:, 2));
        y_circle = cat(2, y_circle, nan(size(y_circle, 1), 1));
        y_circle =  y_circle';
        y_circle = y_circle(:);
        
        hold on;
        myhandle = plot(ImageAxis, ...
            x_circle, y_circle);
        set(myhandle, ...
            'linewidth', lineWidthVal, ...
            'linestyle', lineStyleVal, ...
            'color', circColor, ...
            'tag', 'mycircles');
    end

    function clearDistlineTools(varargin)
        delete(findall(circleFinderFig, 'tag', 'imline'));
        set(gcbo, 'state', 'off');
    end

    function clearMarkedPoints(varargin)
        delete(findall(circleFinderFig, 'tag', 'impoint'));
        set(gcbo, 'state', 'off');
    end

    function exportResults(varargin)
        radii = getappdata(circleFinderFig, 'radii');
        if isempty(radii)
            set(CommentsBox, 'string', 'No circles detected!');
            return
        end
        hasCVST = exist('vision.ShapeInserter', 'class')==8;
        if hasCVST
            prompt={'Export/save CENTERS as:', ...
                'Export/save RADII as:', ...
                'Export/save METRIC as:', ...
				'Export/save BINARY CIRCLE MASK as:', ...
                'Export/save IMAGE as:'};
            defaultanswer={'centers', 'radii', 'metric', 'circleMask', 'ImgOut'};
        else
            prompt={'Export/save CENTERS as:', ...
                'Export/save RADII as:', ...
                'Export/save METRIC as:',...
				'Export/save BINARY CIRCLE MASK as:'};
            defaultanswer={'centers', 'radii', 'metric', 'circleMask'};
        end
        name='Export/save Options (Variable Names)';
        answer=inputdlg(prompt, name, [1,60], defaultanswer);
        if isempty(answer)
            return
        end
        centers = getappdata(circleFinderFig, 'centers');
        if ~isempty(answer{1})
			assignin('base', answer{1}, centers);
		end
        if ~isempty(answer{2})
			assignin('base', answer{2}, radii);
		end
		if ~isempty(answer{3})
			assignin('base', answer{3}, getappdata(circleFinderFig, 'metric'));
		end
		if ~isempty(answer{4})
			[m,n,~] = size(inputImage);
			circleMask = createCirclesMask([m,n],centers,radii);
			assignin('base', answer{4}, circleMask);
		end
        if hasCVST && ~isempty(answer{5})
            if size(inputImage, 3) == 1
                tmpImage = cat(3, inputImage, inputImage, inputImage);
            else
                tmpImage = inputImage;
            end
            tmpImage = im2double(tmpImage);
            h = vision.ShapeInserter;
            h.Shape = 'Circles';
            h.Fill = false;
            h.BorderColor = 'Custom';
            %h.CustomBorderColor = intmax(class(inputImage))*cast(circleColor, class(inputImage));%im2uint16(circleColor);
            h.CustomBorderColor = im2uint8(circleColor);
            h.Antialiasing = true;
			% Note: h.step is preferred here because it doesn't trigger a
			% supposed dependence on the Control System Toolbox. (G1095160)
            %tmp = step(h, tmpImage, uint16([centers radii]));
            tmp = h.step(tmpImage, uint16([centers radii]));
            for ii = 2:round(lineWidthVal)
                %tmp = step(h, tmp, uint16([centers radii+ii-1]));
				tmp = h.step(tmp, uint16([centers radii+ii-1]));
            end
            assignin('base', answer{5}, tmp);
        end
        MinRadius = str2double(get(MinRadiusBox, 'string'));
        MaxRadius = str2double(get(MaxRadiusBox, 'string'));
        Sensitivity = get(SensitivitySlider, 'value');
		Method = get(get(MethodPanel, 'SelectedObject'), 'Tag');
		ObjectPolarity = get(get(ObjectPolarityPanel, 'SelectedObject'), 'Tag');
		EdgeThreshold = get(EdgeThresholdSlider, 'value');
		%
		fprintf('[centers, radii, metric] = imfindcircles(imread(''%s''), [%d %d], ...\n   ''Sensitivity'', %0.4f, ...\n   ''EdgeThreshold'', %0.2f, ...\n   ''Method'', ''%s'', ...\n   ''ObjectPolarity'', ''%s'');\n', ...
			fname, MinRadius, MaxRadius, Sensitivity, EdgeThreshold, Method, ObjectPolarity)
		fprintf('\nOR\n\ndetectCircles = @(x) imfindcircles(x,[%d %d], ...\n\t''Sensitivity'',%0.4f, ...\n\t''EdgeThreshold'',%0.2f, ...\n\t''Method'',''%s'', ...\n\t''ObjectPolarity'',''%s'');', MinRadius, MaxRadius, Sensitivity, EdgeThreshold, Method, ObjectPolarity);
		fprintf('\n[centers, radii, metric] = detectCircles(img);\n\n');
		disp('Variables written to base workspace');
        set(CommentsBox, 'string', sprintf('%d circles detected. Variables written (with requested names) to base workspace.', numel(radii)));
    end

    function GetNewFile(varargin)
        set(gcbo, 'state', 'off');
        [img, cmap, fname, fpath, userCanceled] = getNewImage(false);
        if userCanceled
            return
        end
        if ~isempty(cmap)
            inputImage = ind2rgb(img, cmap);
        else
            inputImage = img;
        end
        cla(ImageAxis);
        ImgObj = imshow(inputImage, 'parent', ImageAxis); %#ok
        originalImg = imshow(img, 'parent', ImageAxis);
        expandAxes(ImageAxis);
        ImgTitle = title(fname, 'interpreter', 'none'); %#ok
        set(ImageAxis, 'XLim', 0.5+[0 size(img, 2)], 'YLim', 0.5+[0 size(img, 1)]);
        processCircleFinder(gcbo)
    end

    function markPoints(varargin)
        markImagePoints(ImageAxis, 'markedPoints', [0 110 110]/255);
        %         waitfor(circleFinderFig, 'currentcharacter')
        %         drawnow;
        set(gcbo, 'state', 'off');
        set(circleFinderFig, 'currentcharacter', '1') % double('1') = 49
        while double(get(circleFinderFig, 'currentcharacter')) == 49
            pause(0.5);
        end
        expandAxes(ImageAxis);
		%6/20/14 Writing to the base workspace is handled by
		%markImagePoints. Instead of repeating the write operation, I just
		%read here from the base workspace.
		pause(0.5); % Just making sure write operation is complete
        markedPoints = evalin('base', 'markedPoints');
		% Consider this instead:
% 		%nPoints = findall(circleFinderFig, 'tag', 'impoint');
% 		markedPoints = cell2mat([...
% 			get(findall(circleFinderFig, 'Tag', 'circle'), 'xData'), ...
% 			get(findall(circleFinderFig, 'Tag', 'circle'), 'yData')]);
% 		assignin('base', 'markedPoints', markedPoints)
        set(CommentsBox, 'string', sprintf('%d points marked. (Locations written to "markedPoints" in base workspace.)', size(markedPoints, 1)));
    end

    function processCircleFinder(varargin)
        drawnow
        cboTag = '';
        try %If processing is from Default-Reset, there is no input argument
            cboTag = get(varargin{1}, 'tag');
        end
        processImmediately = get(ProcessImmediatelyBox, 'value');
        if processImmediately || strcmp(cboTag, 'ProcessButton');
            set(CommentsBox, 'string', 'Processing...please wait.');
            clearPrev = get(ClearPrevious, 'value');
            if clearPrev
                delete(findobj(circleFinderFig, 'tag', 'circleFinderVis'));
            end
            MinRadius = str2double(get(MinRadiusBox, 'string'));
            MaxRadius = str2double(get(MaxRadiusBox, 'string'));
            if MinRadius > MaxRadius
                set(CommentsBox, 'string', 'MinRadius must not be bigger than MaxRadius!');
                return
            end
            Sensitivity = get(SensitivitySlider, 'value');
			EdgeThreshold = get(EdgeThresholdSlider, 'value');
            Method = get(get(MethodPanel, 'SelectedObject'), 'Tag');
            ObjectPolarity = get(get(ObjectPolarityPanel, 'SelectedObject'), 'Tag');
            [centers, radii, metric] = imfindcircles(inputImage, [MinRadius MaxRadius], ...
                'Sensitivity', Sensitivity, ...
                'EdgeThreshold', EdgeThreshold, ...
                'Method', Method, ...
                'ObjectPolarity', ObjectPolarity);
            setappdata(circleFinderFig, 'centers', centers);
            setappdata(circleFinderFig, 'radii', radii);
            setappdata(circleFinderFig, 'metric', metric);
            if numel(radii)>0
                useWhiteBGVal = get(UseWhiteBG, 'value');
                %For visualization
                lineWidthVal = get(LineWidthValBox, 'string');
                tmp = get(LineWidthValBox, 'value');
                lineWidthVal = str2double(lineWidthVal(tmp, :));
                lineStyleVal = get(LineStyleValBox, 'string');
                tmp = get(LineStyleValBox, 'value');
                lineStyleVal = lineStyleVal{tmp};
                circleColor = getappdata(circleColorButton, 'circleColor');
                if useWhiteBGVal
                    hndls = circles(radii, centers, ...
                        lineWidthVal+1, '-', [1 1 1]);
                    set(hndls, 'tag', 'circleFinderVis');
                end
                hndls = circles(radii, centers, ...
                    lineWidthVal, lineStyleVal, circleColor);
                set(hndls, 'tag', 'circleFinderVis', 'hittest', 'off');
                set(CommentsBox, 'string', sprintf('%d circles detected.', numel(radii)));
            else
                set(CommentsBox, 'string', 'No circles detected with these settings!');
            end
        else
            return
        end
    end

    function resetDefaults(varargin)
        set(gcbo, 'state', 'off');
        %Defaults
        set(SensitivitySlider, 'value', 0.85);
        set(SensitivityEdt, 'string', 0.85);
        %
        set(EdgeThresholdSlider, 'value', 0.3);
        set(EdgeThresholdEdt, 'string', 0.3);
        %
        set(BrightButton, 'Value', 1);
        set(DarkButton, 'value', 0);
        %
        set(PhaseCodeButton, 'Value', 1)
        set(TwoStageButton, 'Value', 0);
        %
        set(MinRadiusBox, 'String', '20');
        set(MaxRadiusBox, 'String', '30');
        %
        processCircleFinder
        set(CommentsBox, 'string', 'Parameters reset to default values. (Visualization options not changed)');
    end

% This is disabled. In V1 (FindCirclesGUI), I had a checkbox to unlock the
% EdgeSlider. I decided to eliminate that in this version.
%     function toggleEdgeThreshSlider(varargin)
%         if get(varargin{1}, 'value') == 1
%             set(EdgeSlider, 'enable', 'off');
%         else
%             set(EdgeSlider, 'enable', 'on');
%         end
% 	end
% 
	function toggleZoom(varargin)
		zoom;
 		set(gcbo, 'state', 'off');
	end
end