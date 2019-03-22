function ellipsoid = defineEllipsoid(ellipsoidName)
% 
% defineEllipsoid creates a matlab referenceEllipsoid structure.
% This function was created as a workaround to the referenceEllipsoid function in Matlab for use in Octave.
% Right now only WGS84 is defined, but users can add ellipsoids as they see fit.
%
%
%
% Author:  Andrew Newman
% Email :  anewman@ucar.edu
%
% Arguments: 
%
% Input:
%
%  ellipsoidName, string, name of reference ellipsoid
%
% Output:
%
%  ellipsoid, structure, matlab reference ellipsoid structure
%
  %trim any whitespace, move to uppercase
  ellipsoidName = strtrim(upper(ellipsoidName));
  
  %define ellipsoid structure
  switch ellipsoidName
      case 'WGS84'
          ellipsoid.Code = 7030;
          ellipsoid.Name = 'World Geodetic System 1984';
          ellipsoid.LengthUnit = 'meter';
          ellipsoid.SemimajorAxis = 6378137;
          ellipsoid.SemiminorAxis = 6356752.31424518;
          ellipsoid.InverseFlattening = 298.257223563;
          ellipsoid.Eccentricity = 0.0818191908426215;
          ellipsoid.Flattening = 0.003352810664747;
          ellipsoid.ThirdFlattening = 0.001679220386384;
          ellipsoid.MeanRadius = 6.371008771415059e+06;
          ellipsoid.SurfaceArea = 5.100656217240886e+14;
          ellipsoid.Volume = 1.083207319801408e+21;
      otherwise
          error('Ellipsoid not supported, currently only the WGS84 ellipsoid is supported');
  end

end
