classdef goggleViewInfoPanel<handle
    properties(SetAccess=protected)
        mainPanel
        goggleViewerDisplay
        xLimMin
        xLimMax
        cursorX
        yLimMin
        yLimMax
        cursorY
        zPosition
        viewMode
        downSamplingFactor
        fileName
        
        onDiskIndicator
        onDiskIndicatorLabel
        fileNameLabel
        detailedLoadSupressionButton
        hKeyboardListener
        
        parent
        updateListener
        cursorListener
    end

    properties(Dependent, SetAccess=protected)
        fileNameTruncatedForDisplay
    end
    methods
        %% Constructor
        function obj=goggleViewInfoPanel(parent, hFig, position, gvd)
           
            obj.parent=parent;
            obj.goggleViewerDisplay=gvd; %associated display object
            obj.mainPanel=uipanel(...
                'Parent', hFig, ...
                'Units', 'normalized', ...
                'Position', position);
            fontSz=gbSetting('font.size');
            %% Labels
            
            uicontrol(...
                'Style', 'text', ...
                'Parent', obj.mainPanel, ...
                'Units', 'normalized', ...
                'Position', [0.17 0.875 0.4 0.1], ...
                'String', 'View', ...
                'FontSize', fontSz+2, ...
                'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center');
            uicontrol(...
                'Style', 'text', ...
                'Parent', obj.mainPanel, ...
                'Units', 'normalized', ...
                'Position', [0.57 0.875 0.3 0.1], ...
                'String', 'Cursor', ...
                'FontSize', fontSz+2, ...
                'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center');

            uicontrol(...
                'Style', 'text', ...
                'Parent', obj.mainPanel, ...
                'Units', 'normalized', ...
                'Position', [0.02 0.8 0.2 0.1], ...
                'String', 'X:', ...
                'FontSize', fontSz+2, ...
                'FontWeight', 'bold');
             uicontrol(...
                'Style', 'text', ...
                'Parent', obj.mainPanel, ...
                'Units', 'normalized', ...
                'Position', [0.02 0.7 0.2 0.1], ...
                'String', 'Y:', ...
                'FontSize', fontSz+2, ...
                'FontWeight', 'bold');
             uicontrol(...
                'Style', 'text', ...
                'Parent', obj.mainPanel, ...
                'Units', 'normalized', ...
                'Position', [0.02 0.6 0.2 0.1], ...
                'String', 'Z:', ...
                'FontSize', fontSz+2, ...
                'FontWeight', 'bold');
            
            uicontrol(...
                'Style', 'text', ...
                'Parent', obj.mainPanel, ...
                'Units', 'normalized', ...
                'Position', [0.02 0.4 0.4 0.1], ...
                'String', 'Downsampling:', ...
                'HorizontalAlignment', 'right', ...
                'FontSize', fontSz, ...
                'FontWeight', 'bold');
            uicontrol(...
                'Style', 'text', ...
                'Parent', obj.mainPanel, ...
                'Units', 'normalized', ...
                'Position', [0.02 0.32 0.4 0.1], ...
                'String', 'Image Source:', ...
                'HorizontalAlignment', 'right', ...
                'FontSize', fontSz, ...
                'FontWeight', 'bold');
            obj.onDiskIndicatorLabel=uicontrol(...
                'Style', 'text', ...
                'Parent', obj.mainPanel, ...
                'Units', 'normalized', ...
                'Position', [0.02 0.24 0.4 0.1], ...
                'String', 'Original Image:', ...
                'HorizontalAlignment', 'right', ...
                'FontSize', fontSz, ...
                'FontWeight', 'bold');
           %% cursor position
            obj.xLimMin=uicontrol(...
                'Style', 'text', ...
                'Parent', obj.mainPanel, ...
                'Units', 'normalized', ...
                'Position', [0.17 0.8 0.2 0.1], ...
                'String', '', ...
                'FontSize', fontSz);
            obj.xLimMax=uicontrol(...
                'Style', 'text', ...
                'Parent', obj.mainPanel, ...
                'Units', 'normalized', ...
                'Position', [0.37 0.8 0.2 0.1], ...
                'String', '', ...
                'FontSize', fontSz);
            obj.cursorX=uicontrol(...
                'Style', 'text', ...
                'Parent', obj.mainPanel, ...
                'Units', 'normalized', ...
                'Position', [0.57 0.8 0.3 0.1], ...
                'String', '', ...
                'FontSize', fontSz);
            
             obj.yLimMin=uicontrol(...
                'Style', 'text', ...
                'Parent', obj.mainPanel, ...
                'Units', 'normalized', ...
                'Position', [0.17 0.7 0.2 0.1], ...
                'String', '', ...
                'FontSize', fontSz);
            obj.yLimMax=uicontrol(...
                'Style', 'text', ...
                'Parent', obj.mainPanel, ...
                'Units', 'normalized', ...
                'Position', [0.37 0.7 0.2 0.1], ...
                'String', '', ...
                'FontSize', fontSz);
            obj.cursorY=uicontrol(...
                'Style', 'text', ...
                'Parent', obj.mainPanel, ...
                'Units', 'normalized', ...
                'Position', [0.57 0.7 0.3 0.1], ...
                'String', '', ...
                'FontSize', fontSz);
            
             obj.zPosition=uicontrol(...
                'Style', 'text', ...
                'Parent', obj.mainPanel, ...
                'Units', 'normalized', ...
                'Position', [0.17 0.6 0.66 0.1], ...
                'String', '', ...
                'FontSize', fontSz, ...
                'HorizontalAlignment', 'center');
            %% Image display info
             obj.downSamplingFactor=uicontrol(...
                'Style', 'text', ...
                'Parent', obj.mainPanel, ...
                'Units', 'normalized', ...
                'Position', [0.44 0.4 0.55 0.1], ...
                'String', '', ...
                'FontSize', fontSz, ...
                'HorizontalAlignment', 'left');
             obj.viewMode=uicontrol(...
                'Style', 'text', ...
                'Parent', obj.mainPanel, ...
                'Units', 'normalized', ...
                'Position', [0.44 0.32 0.55 0.1], ...
                'String', '', ...
                'FontSize', fontSz, ...
                'HorizontalAlignment', 'left');
            obj.onDiskIndicator=uicontrol(...
                'Style', 'text', ...
                'Parent', obj.mainPanel, ...
                'Units', 'normalized', ...
                'Position', [0.44 0.24 0.55 0.1], ...
                'String', '', ...
                'FontSize', fontSz, ...
                'HorizontalAlignment', 'left');
            obj.fileName=uicontrol(...
                'Style', 'text', ...
                'Parent', obj.mainPanel, ...
                'Units', 'normalized', ...
                'Position', [0.04 0.17 0.92 0.1], ...
                'String', '', ...
                'FontSize', fontSz-1, ...
                'HorizontalAlignment', 'left');
            %% Detailed load supression
            obj.detailedLoadSupressionButton=uicontrol(...
                'Style', 'checkbox', ...
                'Parent', obj.mainPanel, ...
                'Units', 'normalized', ...
                'Position', [0.05 0.08 0.9 0.08], ...
                'String', 'Suppress detailed view loading (q)', ...
                'FontSize', fontSz-1, ...
                'HorizontalAlignment', 'left', ...
                'Callback', @dlSuppressValueChange);
            obj.hKeyboardListener=event.listener(obj.parent, 'KeyPress', @obj.handleMainWindowKeyPress);
            obj.updateDisplay();
            %% Set Colors
            obj.mainPanel.BackgroundColor=gbSetting('viewer.panelBkgdColor');
            set(obj.mainPanel.Children,'BackgroundColor', gbSetting('viewer.panelBkgdColor'))
            set(obj.mainPanel.Children,'ForegroundColor', gbSetting('viewer.textMainColor'))
            
           %% Add listeners
           obj.updateListener=event.listener(parent, 'ViewChanged', @obj.updateDisplay);
            obj.cursorListener=event.listener(parent, 'CursorPositionChangedWithinImageAxes', @obj.updateCurrentCursorPosition);
        end
        %% Update Display
        function updateDisplay(obj, ~, ~)
            doUpdate(obj)
        end
        function updateCurrentCursorPosition(obj, ~, evData)
            C=round(evData.CursorPosition);
            x=C(1, 1);
            y=C(2, 2);
            
            obj.cursorX.String=x;
            obj.cursorY.String=y;
        end
        function showFileOnDiskStatus(obj)
            
            gvd=obj.goggleViewerDisplay;
            zvm=gvd.zoomedViewManager;
            
            zoomLevel=gvd.zoomLevel;
            
            if zoomLevel<=gbSetting('viewerDisplay.minZoomLevelForDetailedLoad')
                obj.onDiskIndicator.Visible='off';
                obj.onDiskIndicatorLabel.Visible='off';
            else
                obj.onDiskIndicatorLabel.Visible='on';
                obj.onDiskIndicator.Visible='on';
                
                if ~zvm.currentSliceFileExistsOnDisk
                    obj.onDiskIndicator.String='NOT FOUND';
                    obj.onDiskIndicator.ForegroundColor =gbSetting('viewInfoPanel.fileNotOnDiskTextColor');
                else
                    obj.onDiskIndicator.String='On Disk';
                    obj.onDiskIndicator.ForegroundColor = gbSetting('viewInfoPanel.fileOnDiskTextColor');
                end
            end
        end
        %% Getters
        function fn=get.fileNameTruncatedForDisplay(obj)
            zvm=obj.goggleViewerDisplay.zoomedViewManager;
            [~, nm, ext]=fileparts(zvm.currentSliceFileName);
            
            spName=obj.goggleViewerDisplay.overviewStack.sampleName;

            nm=strrep(nm, spName, '');     %Get rid of experiment name, it's uninteresting
            if nm(1)=='_'                   %Get rid of leading underscores
                nm=nm(2:end);
            end
            fn=[nm ext];
        end
        %% Methods
        function handleMainWindowKeyPress(obj, ~,ev)
            keyPress([], ev.KeyPressData, obj)
        end
        %% Destructor
        function delete(obj)
            if obj.detailedLoadSupressionButton.Value==1
                obj.detailedLoadSupressionButton.Value=0;
                dlSuppressValueChange(obj.detailedLoadSupressionButton)
            end
            delete(obj.mainPanel)
        end
    end
end

function doUpdate(obj)
    goggleDebugTimingInfo(1, 'GVIP: Beginning asynchronous ViewInfo update',toc, 's')

    %% Update view limit coordinates
    xl=round(xlim(obj.goggleViewerDisplay.axes));
    obj.xLimMin.String=sprintf('%i', xl(1));
    obj.xLimMax.String=sprintf('%i', xl(2));
    
    
    yl=round(ylim(obj.goggleViewerDisplay.axes));
    obj.yLimMin.String=sprintf('%i',yl(1));
    obj.yLimMax.String=sprintf('%i',yl(2));
    
    zIdx=obj.goggleViewerDisplay.currentIndex;
    zIdxOriginalVoxels=obj.goggleViewerDisplay.currentZPlaneOriginalVoxels;
    
    zActual=obj.goggleViewerDisplay.overviewStack.zCoordsUnits(zIdx);
    obj.zPosition.String=sprintf('%04i (%ium)', zIdxOriginalVoxels, round(zActual));
    
    %% Zoom info and file status. File name info.
    
    gvd=obj.goggleViewerDisplay;
    zvm=gvd.zoomedViewManager;
    
    zoomLevel=gvd.zoomLevel;
    dsFactor=gvd.downSamplingForCurrentZoomLevel;
    stackDsFactor=gvd.overviewStack.xyds;
    
    if zoomLevel<=gbSetting('viewerDisplay.minZoomLevelForDetailedLoad')
        obj.viewMode.String='In Memory';
        obj.downSamplingFactor.String=sprintf('%ux',stackDsFactor);
        obj.fileName.String='';
    else
        %% Update source and ds indicators
        if ~zvm.currentSliceFileExistsOnDisk
            obj.viewMode.String='In Memory';
            obj.downSamplingFactor.String=sprintf('%ux',stackDsFactor);
            obj.fileName.ForegroundColor=hsv2rgb([0.05 1 0.8]);
        else
            if dsFactor>1
                obj.viewMode.String='From Disk';
                obj.downSamplingFactor.String=sprintf('%ux', dsFactor);
            elseif dsFactor==1
                obj.viewMode.String='From Disk';
                obj.downSamplingFactor.String='1x (None)';
            else
                error('Unrecognised downSampling/zoomLevels')
            end
            obj.fileName.ForegroundColor = gbSetting('viewInfoPanel.fileOnDiskTextColor');
        end
        obj.fileName.String=['(' obj.fileNameTruncatedForDisplay, ')'];
        
    end
    
    obj.showFileOnDiskStatus;
    
    goggleDebugTimingInfo(1, 'GVIP: ViewInfo update (asynchronous) complete',toc, 's')
    
end

function dlSuppressValueChange(obj, ~)
if isempty(obj.UserData)
    obj.UserData=gbSetting('viewerDisplay.minZoomLevelForDetailedLoad');
    gbSetting('viewerDisplay.minZoomLevelForDetailedLoad', Inf)
else    
    gbSetting('viewerDisplay.minZoomLevelForDetailedLoad', obj.UserData)
    obj.UserData=[];
end
end

function keyPress(~, eventdata, obj)
    key=eventdata.Key;
    ctrlMod=ismember('control', eventdata.Modifier);
    
    if strcmp(key, 'q') && ~ctrlMod
        obj.detailedLoadSupressionButton.Value=~obj.detailedLoadSupressionButton.Value;
        dlSuppressValueChange(obj.detailedLoadSupressionButton)
    end
end
