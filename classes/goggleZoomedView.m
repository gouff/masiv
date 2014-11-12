classdef goggleZoomedView<handle
    properties(SetAccess=protected)
        imageData
    end
    properties(SetAccess=protected)
        regionSpec
        downSampling
        filePath
        parentZoomedViewManager
        x
        y
        z
    end
    properties(SetAccess=protected, Dependent)
        sizeMB
        imageInMemory
    end
    
    methods
        %% Constructor
        function obj=goggleZoomedView(filePath, regionSpec, downSampling, z, parentZoomedViewManager)
            if nargin>0
                goggleDebugTimingInfo(3, 'GZV Constructor: starting', toc,'s')
                obj.regionSpec=regionSpec;
                obj.downSampling=downSampling;
                obj.filePath=filePath;
                
                obj.x=obj.regionSpec(1):obj.downSampling:obj.regionSpec(1)+obj.regionSpec(3)-1;
                obj.y=obj.regionSpec(2):obj.downSampling:obj.regionSpec(2)+obj.regionSpec(4)-1;
                obj.z=z;
                
                obj.parentZoomedViewManager=parentZoomedViewManager;
                
                goggleDebugTimingInfo(3, 'GZV Constructor: completed, calling loadViewImageInBackground...', toc,'s')
                loadViewImageInBackground(obj)
            else
                obj.z=-1;
            end
        end
        %% Getters
        function szMB=get.sizeMB(obj)
            szBytes=numel(obj.imageData)*2; % 16 bit images
            szMB=szBytes/(1000*1000);
        end
        function inmem=get.imageInMemory(obj)
            inmem=~isempty(obj.imageData);
        end
       
    end
end

function loadViewImageInBackground(obj)
goggleDebugTimingInfo(3, 'GZV.loadViewImageInBackground starting', toc,'s')
p=gcp();

f=parfeval(p, @openTiff, 1, obj.filePath, obj.regionSpec, obj.downSampling);
goggleDebugTimingInfo(3, 'GZV.loadViewImageInBackground: parfeval started', toc,'s')
drawnow
t=timer('BusyMode', 'queue', 'ExecutionMode', 'fixedRate', 'Period', 0.01, 'TimerFcn', {@checkForLoadedImage, obj, f});
goggleDebugTimingInfo(3, 'GZV.loadViewImageInBackground: Timer created', toc,'s')
start(t)
goggleDebugTimingInfo(3, 'GZV.loadViewImageInBackground: Timer started', toc,'s')



end

function checkForLoadedImage(t, ~, obj, f)
 [idx, r]=fetchNext(f, 0.001);
    if ~isempty(idx)
        goggleDebugTimingInfo(3, 'GZV.checkForLoadedImage: Image has been loaded', toc,'s')
        obj.imageData=r;
        goggleDebugTimingInfo(3, 'GZV.checkForLoadedImage: Image data read', toc,'s')
        stop(t)
        goggleDebugTimingInfo(3, 'GZV.checkForLoadedImage: Timer stopped', toc,'s')
        delete(t)
        goggleDebugTimingInfo(3, 'GZV.checkForLoadedImage: Timer deleted', toc,'s')
        goggleDebugTimingInfo(3, 'GZV.checkForLoadedImage: Calling ZVM updateView...', toc,'s')
        obj.parentZoomedViewManager.updateView();
    end
end
