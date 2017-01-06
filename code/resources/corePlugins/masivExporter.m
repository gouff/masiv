classdef masivExporter<masivPlugin
    %masivExporter Exports a stack to the base workspace or to a file
    properties(Access=protected)
        hFig
        hPanelPosition
        hXPositionMin
        hYPositionMin
        hXPositionMax
        hYPositionMax
        hZSelectionMin
        hZSelectionMax
        
        
        hPanelResult
        hXSize
        hYSize
        hZSize
        hNPixels
        
        hChannels
        
        hPnlFormat
        h8Bit
        h16Bit
        
        hName
        
        hPnlDestination
        hDestDisk
        hDestWorkspace
        hDestPath
        hDestPathSelect
        
        fontName
        fontSize
        hSelectionRectangle
    end
    
    properties(Access=protected, Dependent)
        maxSliceNum
    end
    
    methods
        function obj=masivExporter(caller, ~)
            obj=obj@masivPlugin(caller);
           
            %% Settings
            obj.fontName=masivSetting('font.name');
            obj.fontSize=masivSetting('font.size');
            try
                pos=masivSetting('exporter.figurePosition');
            catch
                ssz=get(0, 'ScreenSize');
                lb=[ssz(3)/3 ssz(4)/3];
                pos=round([lb 400 550]);
                masivSetting('exporter.figurePosition', pos)
            end
            
            %% Main UI
            obj.hFig=figure(...
                'Position', pos, ...
                'CloseRequestFcn', {@deleteRequest, obj}, ...
                'MenuBar', 'none', ...
                'NumberTitle', 'off', ...
                'Name', ['Stack Exporter: ' obj.MaSIV.Meta.stackName], ...
                'Color', masivSetting('viewer.panelBkgdColor'));
            
            %% Export Position Indicators & Z selection
            obj.hPanelPosition=uipanel(...
                'Parent', obj.hFig, ...
                'Units', 'normalized', ...
                'Position', [0.05 0.65 0.58 0.3], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontSize', obj.fontSize+1, ...
                'Title', 'Export Region');
            
            uicontrol(...
                'Style', 'text', ...
                'HorizontalAlignment', 'right', ...
                'Parent', obj.hPanelPosition, ...
                'Units', 'normalized', ...
                'Position', [0.05 0.7 0.1 0.2], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize, ...
                'String', 'X:');
            uicontrol(...
                'Style', 'text', ...
                'HorizontalAlignment', 'right', ...
                'Parent', obj.hPanelPosition, ...
                'Units', 'normalized', ...
                'Position', [0.05 0.45 0.1 0.2], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize, ...
                'String', 'Y:');
             uicontrol(...
                'Style', 'text', ...
                'HorizontalAlignment', 'right', ...
                'Parent', obj.hPanelPosition, ...
                'Units', 'normalized', ...
                'Position', [0.05 0.2 0.1 0.2], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize, ...
                'String', 'Z:');
            
            obj.hXPositionMin=uicontrol(...
                'Style', 'text', ...
                'HorizontalAlignment', 'center', ...
                'Parent', obj.hPanelPosition, ...
                'Units', 'normalized', ...
                'Position', [0.2 0.7 0.3 0.2], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize);
             obj.hYPositionMin=uicontrol(...
                'Style', 'text', ...
                'HorizontalAlignment', 'center', ...
                'Parent', obj.hPanelPosition, ...
                'Units', 'normalized', ...
                'Position', [0.2 0.45 0.3 0.2], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize);
            
             obj.hXPositionMax=uicontrol(...
                'Style', 'text', ...
                'HorizontalAlignment', 'center', ...
                'Parent', obj.hPanelPosition, ...
                'Units', 'normalized', ...
                'Position', [0.6 0.7 0.3 0.2], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize);
             obj.hYPositionMax=uicontrol(...
                'Style', 'text', ...
                'HorizontalAlignment', 'center', ...
                'Parent', obj.hPanelPosition, ...
                'Units', 'normalized', ...
                'Position', [0.6 0.45 0.3 0.2], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize);
           
            obj.hZSelectionMin=uicontrol(...
                'Style', 'edit', ...
                'HorizontalAlignment', 'center', ...
                'Parent', obj.hPanelPosition, ...
                'Units', 'normalized', ...
                'Position', [0.25 0.275 0.2 0.15], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize, ...
                'String', '1', ...
                'Callback', @(h,e) obj.updateInfo);
            obj.hZSelectionMax=uicontrol(...
                'Style', 'edit', ...
                'HorizontalAlignment', 'center', ...
                'Parent', obj.hPanelPosition, ...
                'Units', 'normalized', ...
                'Position', [0.65 0.275 0.2 0.15], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize, ...
                'String', obj.maxSliceNum, ...
                'Callback', @(h,e) obj.updateInfo);
            
            uicontrol(...
                'Style', 'pushbutton', ...
                'HorizontalAlignment', 'center', ...
                'Parent', obj.hPanelPosition, ...
                'Units', 'normalized', ...
                'Position', [0.2 0.05 0.3 0.15], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize, ...
                'String', 'Current', ...
                'Callback', @(h,e) setCurrentSlice(h,e,obj, obj.hZSelectionMin));
            uicontrol(...
                'Style', 'pushbutton', ...
                'HorizontalAlignment', 'center', ...
                'Parent', obj.hPanelPosition, ...
                'Units', 'normalized', ...
                'Position', [0.6 0.05 0.3 0.15], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize, ...
                'String', 'Current', ...
                'Callback', @(h,e) setCurrentSlice(h,e,obj, obj.hZSelectionMax));
            
            %% Which channels
            
            cropPanel=uipanel(...
                'Parent', obj.hFig, ...
                'Units', 'normalized', ...
                'Position', [0.65 0.65 0.3 0.3], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontSize', obj.fontSize+1, ...
                'Title', 'Channels');
            
            channels=fieldnames(obj.Meta.imageFilePaths);
            obj.hChannels=uicontrol(...
                'Parent', cropPanel, ...
                'Units', 'normalized', ...
                'Position', [0.05 0.05 0.9 0.9], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize, ...
                'Style', 'listbox', ...
                'Max', 10, 'Min', 2, ...
                'Value', 1:numel(channels),...
                'String',channels);
            
            %% Export Result Indicator
            obj.hPanelResult=uipanel(...
                'Parent', obj.hFig, ...
                'Units', 'normalized', ...
                'Position', [0.05 0.37 0.58 0.28], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontSize', obj.fontSize+1, ...
                'Title', 'Stack Size');
            uicontrol(...
                'Style', 'text', ...
                'HorizontalAlignment', 'right', ...
                'Parent', obj.hPanelResult, ...
                'Units', 'normalized', ...
                'Position', [0.1 0.75 0.2 0.2], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize, ...
                'String', 'X:');
            uicontrol(...
                'Style', 'text', ...
                'HorizontalAlignment', 'right', ...
                'Parent', obj.hPanelResult, ...
                'Units', 'normalized', ...
                'Position', [0.1 0.55 0.2 0.2], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize, ...
                'String', 'Y:');
            uicontrol(...
                'Style', 'text', ...
                'HorizontalAlignment', 'right', ...
                'Parent', obj.hPanelResult, ...
                'Units', 'normalized', ...
                'Position', [0.1 0.35 0.2 0.2], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize, ...
                'String', 'Z:');
            
             uicontrol(...
                'Style', 'text', ...
                'HorizontalAlignment', 'right', ...
                'Parent', obj.hPanelResult, ...
                'Units', 'normalized', ...
                'Position', [0.05 0.15 0.25 0.2], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize, ...
                'String', 'Size:');
            
            obj.hXSize=uicontrol(...
                'Style', 'text', ...
                'HorizontalAlignment', 'left', ...
                'Parent', obj.hPanelResult, ...
                'Units', 'normalized', ...
                'Position', [0.35 0.75 0.6 0.2], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize);
            obj.hYSize=uicontrol(...
                'Style', 'text', ...
                'HorizontalAlignment', 'left', ...
                'Parent', obj.hPanelResult, ...
                'Units', 'normalized', ...
                'Position', [0.35 0.55 0.6 0.2], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize);
             obj.hZSize=uicontrol(...
                'Style', 'text', ...
                'HorizontalAlignment', 'left', ...
                'Parent', obj.hPanelResult, ...
                'Units', 'normalized', ...
                'Position', [0.35 0.35 0.6 0.2], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize);
            obj.hNPixels=uicontrol(...
                'Style', 'text', ...
                'HorizontalAlignment', 'left', ...
                'Parent', obj.hPanelResult, ...
                'Units', 'normalized', ...
                'Position', [0.35 0.15 0.6 0.2], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize);
            
            %% Format Selection 
            obj.hPnlFormat=uibuttongroup(...
                'Parent', obj.hFig, ...
                'Units', 'normalized', ...
                'Position', [0.65 0.37 0.3 0.28], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontSize', obj.fontSize+1, ...
                'Title', 'Format', ...
                'SelectionChangedFcn', @(h,e) updateInfo(obj));
            
            obj.h8Bit=uicontrol(...
                'Style', 'radiobutton', ...
                'HorizontalAlignment', 'left', ...
                'Parent', obj.hPnlFormat, ...
                'Units', 'normalized', ...
                'Position', [0.1 0.65 0.8 0.3], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize, ...
                'String', '8 Bit', ...
                'UserData', 8);
            obj.h16Bit=uicontrol(...
                'Style', 'radiobutton', ...
                'HorizontalAlignment', 'left', ...
                'Parent', obj.hPnlFormat, ...
                'Units', 'normalized', ...
                'Position', [0.1 0.3 0.8 0.3], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize, ...
                'String', '16 Bit', ...
                'UserData', 16);
            
            switch class(obj.MaSIV.mainDisplay.currentImageViewData)
                case 'uint8'
                    obj.h8Bit.Value=1;
                case 'uint16'
                    obj.h16Bit.Value=1;
                otherwise
                    obj.h8Bit.Value=1;
            end
            
            %% Name
            pnlName=uipanel(...
                'Parent', obj.hFig, ...
                'Units', 'normalized', ...
                'Position', [0.05 0.25 0.9 0.12], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontSize', obj.fontSize+1, ...
                'Title', 'Name');
            obj.hName=uicontrol(...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left', ...
                'Parent', pnlName, ...
                'Units', 'normalized', ...
                'Position', [0.05 0.3 0.9 0.5], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize, ...
                'String', obj.MaSIV.Meta.stackName);
            
            %% Destination Selection
            obj.hPnlDestination=uibuttongroup(...
                'Parent', obj.hFig, ...
                'Units', 'normalized', ...
                'Position', [0.05 0.1 0.9 0.15], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontSize', obj.fontSize+1, ...
                'Title', 'Destination', ...
                'SelectionChangedFcn', @(h,e) changeDestinationSelection(h, obj));
            
            obj.hDestWorkspace=uicontrol(...
                'Style', 'radiobutton', ...
                'HorizontalAlignment', 'left', ...
                'Parent', obj.hPnlDestination, ...
                'Units', 'normalized', ...
                'Position', [0.05 0.6 0.3 0.35], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize, ...
                'String', 'Workspace');
            
            obj.hDestDisk=uicontrol(...
                'Style', 'radiobutton', ...
                'HorizontalAlignment', 'right', ...
                'Parent', obj.hPnlDestination, ...
                'Units', 'normalized', ...
                'Position', [0.05 0.1 0.2 0.45], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize, ...
                'String', 'Disk:', ...
                'Value', 1);
            obj.hDestPath=uicontrol(...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left', ...
                'Parent', obj.hPnlDestination, ...
                'Units', 'normalized', ...
                'Position', [0.25 0.125 0.55 0.4], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize, ...
                'String', masivSetting('defaultDirectory'));
            obj.hDestPathSelect=uicontrol(...
                'Style', 'pushbutton', ...
                'HorizontalAlignment', 'center', ...
                'Parent', obj.hPnlDestination, ...
                'Units', 'normalized', ...
                'Position', [0.825 0.125 0.15 0.4], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize, ...
                'String', '...', ...
                'Callback', @(h,e) selectPath(obj));
            
            %% Selection Rectangle
            obj.hSelectionRectangle=imrect(obj.MaSIV.hMainImgAx, getRectangleInitialPosition(obj));
            obj.updateInfo(getRectangleInitialPosition(obj))
            obj.hSelectionRectangle.Deletable=0;
            setRectangleConstraints(obj)
            
            %% Buttons
            uicontrol(...
                'Style', 'pushbutton', ...
                'HorizontalAlignment', 'center', ...
                'Parent', obj.hFig, ...
                'Units', 'normalized', ...
                'Position', [0.7 0.02 0.25 0.06], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize, ...
                'String', 'OK', ...
                'Callback', @(~,~) obj.doExport);
            uicontrol(...
                'Style', 'pushbutton', ...
                'HorizontalAlignment', 'center', ...
                'Parent', obj.hFig, ...
                'Units', 'normalized', ...
                'Position', [0.43 0.02 0.25 0.06], ...
                'BackgroundColor', masivSetting('viewer.mainBkgdColor'), ...
                'ForegroundColor', masivSetting('viewer.textMainColor'), ...
                'FontName', obj.fontName, ...
                'FontSize', obj.fontSize, ...
                'String', 'Cancel', ...
                'Callback', @(~,~) close(obj.hFig));
        end
        
        function updateInfo(obj, p,~)
            if nargin<2||isempty(p)
                p(1)=str2num(obj.hXPositionMin.String);      %#ok<ST2NM>
                p(2)=str2num(obj.hYPositionMin.String);      %#ok<ST2NM>
                p(3)=str2num(obj.hXPositionMax.String)-p(1); %#ok<ST2NM>
                p(4)=str2num(obj.hYPositionMax.String)-p(2); %#ok<ST2NM>
            else
                obj.hXPositionMin.String=sprintf('%u', round(p(1)));
                obj.hYPositionMin.String=sprintf('%u', round(p(2)));
                obj.hXPositionMax.String=sprintf('%u', round(p(1)+p(3)));
                obj.hYPositionMax.String=sprintf('%u', round(p(2)+p(4)));
            end
            Z=str2num(obj.hZSelectionMax.String)-str2num(obj.hZSelectionMin.String)+1; %#ok<ST2NM>
            
            obj.hXSize.String=sprintf('%u', round(p(3)));
            obj.hYSize.String=sprintf('%u', round(p(4)));
            obj.hZSize.String=sprintf('%u', Z); 
            
            nPixels=round(p(3))*round(p(4))*Z;
            
            if nPixels<1e7
                pxStr=sprintf('%3.2f MPix', nPixels/1e6);
            elseif nPixels<1e8
                pxStr=sprintf('%3.1f MPix', nPixels/1e6);
            elseif nPixels<1e9
                pxStr=sprintf('%3.0f MPix', nPixels/1e6);
            elseif nPixels<1e10
                pxStr=sprintf('%3.2f GPix', nPixels/1e9);
            elseif nPixels<1e11
                pxStr=sprintf('%3.1f GPix', nPixels/1e9);
            elseif nPixels<1e12
                pxStr=sprintf('%3.0f GPix', nPixels/1e9);
            elseif nPixels<1e13
                pxStr=sprintf('%3.2f TPix', nPixels/1e12);
            elseif nPixels<1e13
                pxStr=sprintf('%3.1f TPix', nPixels/1e12);
            else
                pxStr=sprintf('%3.0f TPix', nPixels/1e12);
            end
            
            pxStr=[pxStr sprintf('\n')];
            nBytes=obj.hPnlFormat.SelectedObject.UserData*nPixels/8;
            
            if nBytes<1e7
                pxStr=[pxStr sprintf('%3.2f MB', nBytes/1e6)];
            elseif nBytes<1e8
                pxStr=[pxStr sprintf('%3.1f MB', nBytes/1e6)];
            elseif nBytes<1e9
                pxStr=[pxStr sprintf('%3.0f MB', nBytes/1e6)];
            elseif nBytes<1e10
                pxStr=[pxStr sprintf('%3.2f GB', nBytes/1e9)];
            elseif nBytes<1e11
                pxStr=[pxStr sprintf('%3.1f GB', nBytes/1e9)];
            elseif nBytes<1e12
                pxStr=[pxStr sprintf('%3.0f GB', nBytes/1e9)];
            elseif nBytes<1e13
                pxStr=[pxStr sprintf('%3.2f TB', nBytes/1e12)];
            elseif nBytes<1e13
                pxStr=[pxStr sprintf('%3.1f TB', nBytes/1e12)];
            else
                pxStr=[pxStr sprintf('%3.0f TB', nBytes/1e12)];
            end
            
                pxStr=[pxStr ' per stack'];
            obj.hNPixels.String=pxStr;
            
            
            
        end
        
        function doExport(obj)
            %% Params
            channelsToLoad=obj.hChannels.String(obj.hChannels.Value);
            
            switch obj.hPnlFormat.SelectedObject.String
                case '8 Bit'
                    format='uint8';
                case '16 Bit'
                    format='uint16';
            end
            
            regionSpec(1)=str2num(obj.hXPositionMin.String);                 %#ok<ST2NM>
            regionSpec(2)=str2num(obj.hYPositionMin.String);                 %#ok<ST2NM>
            regionSpec(3)=str2num(obj.hXPositionMax.String)-regionSpec(1);   %#ok<ST2NM>
            regionSpec(4)=str2num(obj.hYPositionMax.String)-regionSpec(2);   %#ok<ST2NM>
            
            idx=str2num(obj.hZSelectionMin.String):str2num(obj.hZSelectionMax.String);    %#ok<ST2NM>
            
            
            t=obj.MaSIV.Meta;
            
            %%
            for ii=1:numel(channelsToLoad)
                
                I=zeros(regionSpec(4),regionSpec(3), numel(idx), format);
                
                %%
                c=channelsToLoad{ii};
                swb=SuperWaitBar(numel(idx), sprintf('Generating Stack #%u of %u', ii, numel(channelsToLoad)));
                 
                parfor jj=1:numel(idx)
                    f=t.imageFilePaths.(c){idx(jj)}; %#ok<PFBNS>
                    fName=fullfile(t.imageBaseDirectory, f);
                    
                    info=imfinfo(fName);
                    [xoffset, yoffset]=masiv.fileio.checkTiffFileForOffset(info);
                    regionSpecAdjustedForCrop=regionSpec-[xoffset yoffset 0 0];
                    
                    I(:,:,jj)=masiv.fileio.openTiff(fName, regionSpecAdjustedForCrop);
                    swb.progress; %#ok<PFBNS>
                end
                delete(swb)
                clear swb
                switch obj.hPnlDestination.SelectedObject.String
                    case 'Workspace'
                        assignin('base', [obj.hName.String '_' c], I)
                    case 'Disk:'
                        masiv.fileio.saveTiffStack(I, fullfile(obj.hDestPath.String, [obj.hName.String '_' c '.tif']), 'g');
                end
            end
            
            s.stackName=t.stackName;
            s.region=regionSpec;
            s.idx=idx;
            s.format=format;
            switch obj.hPnlDestination.SelectedObject.String
                    case 'Workspace'
                        assigin('base', [obj.hName.String '_' 'params'], s);
                    case 'Disk:'
                        masiv.yaml.writeSimpleYAML(s, fullfile(obj.hDestPath.String, [obj.hName.String '.yml']));
            end
            close(obj.hFig)

        end
        
        %% Getters
        function sn=get.maxSliceNum(obj)
            
            fnames=fieldnames(obj.Meta.imageFilePaths);
            sn=numel(obj.Meta.imageFilePaths.(fnames{1}));
            
        end
        
    end
    
    methods(Static)
        function d=displayString()
            d='Export Stack...';
        end
    end
    
end

%% Callbacks
function deleteRequest(~, ~, obj)
    deleteRequest@masivPlugin(obj)
    delete(obj.hFig);
    delete(obj.hSelectionRectangle);
    delete(obj);
end

%% Utils
function initPos=getRectangleInitialPosition(obj)
    xl=obj.MaSIV.hMainImgAx.XLim;
    yl=obj.MaSIV.hMainImgAx.YLim;
    
    initPos=round([xl(1)+range(xl)/5 yl(1)+range(yl)/5 range(xl)*3/5 range(yl)*3/5]);
end

function setRectangleConstraints(obj)
    fcn=makeConstrainToRectFcn('imrect',obj.MaSIV.mainDisplay.imageXLimOriginalCoords, obj.MaSIV.mainDisplay.imageYLimOriginalCoords);
    setPositionConstraintFcn(obj.hSelectionRectangle,fcn);
    
    addNewPositionCallback(obj.hSelectionRectangle,@obj.updateInfo);
end

function setCurrentSlice(~,~,obj, boxToSet)
    boxToSet.String=obj.MaSIV.mainDisplay.currentZPlaneOriginalVoxels;
    obj.updateInfo
end

function selectPath(obj)
p=uigetdir(obj.hDestPath.String, 'Select Export Directory');
if ~isempty(p) && ~isnumeric(p) && exist(p, 'dir')
    obj.hDestPath.String=p;
end
end

function changeDestinationSelection(h,obj)
    switch h.SelectedObject.String
        case 'Disk:'
            obj.hDestPath.Enable='on';
            obj.hDestPathSelect.Enable='on';
        otherwise
            obj.hDestPath.Enable='inactive';
            obj.hDestPathSelect.Enable='inactive';
    end
end

