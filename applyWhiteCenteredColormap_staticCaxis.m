function applyWhiteCenteredColormap_staticCaxis(whiteMin, whiteMax, nColors)
% APPLYWHITECENTEREDCOLORMAP_STATICCAXIS
% Applies a blue-white-red colormap centered on [whiteMin, whiteMax],
% scaled to the current color axis range (from previous plot).
% The caxis remains unchanged.
%
% Usage:
%   applyWhiteCenteredColormap_staticCaxis();              % defaults to [-0.1, 0.1]
%   applyWhiteCenteredColormap_staticCaxis(-0.2, 0.2);      % custom white band
%   applyWhiteCenteredColormap_staticCaxis(-0.1, 0.1, 256); % custom resolution

    if nargin < 1, whiteMin = -0.1; end
    if nargin < 2, whiteMax =  0.1; end
    if nargin < 3, nColors  = 256; end

    % Get current color axis limits (auto-determined by data)
    lims = caxis;  % [cmin, cmax]
    cmin = lims(1);
    cmax = lims(2);

    if whiteMin <= cmin, whiteMin = cmin + eps; end
    if whiteMax >= cmax, whiteMax = cmax - eps; end
    if whiteMin >= whiteMax
        warning('Invalid white band: whiteMin must be less than whiteMax');
        return;
    end

    % Proportional color segment sizes
    rangeTotal = cmax - cmin;
    nBlue  = round((whiteMin - cmin) / rangeTotal * nColors);
    nWhite = round((whiteMax - whiteMin) / rangeTotal * nColors);
    nRed   = nColors - nBlue - nWhite;

    % Prevent zero-length segments
    nBlue  = max(nBlue, 1);
    nWhite = max(nWhite, 1);
    nRed   = max(nRed, 1);

    % Build segments
    blue  = [linspace(0,1,nBlue)' linspace(0,1,nBlue)' ones(nBlue,1)];
    white = ones(nWhite, 3);
    red   = [ones(nRed,1) linspace(1,0,nRed)' linspace(1,0,nRed)'];

    % Combine and apply (without changing caxis)
    colormap([blue; white; red]);
end
