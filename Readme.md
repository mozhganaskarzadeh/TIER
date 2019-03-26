# STIR
Repository for the Simple Topographically Informed Regression (STIR)

The STIR tool was motivated by the desire to explore methodological choices in 'knowledge-based' spatial mapping algorithms.  These algorithms incorporate knowledge of atmospheric processes and their interaction with the landscape with geophysical attributes to inform statistical regression models that map meteorology variables to a grid.  STIR follows the knowledge-based concepts put forth in Daly et al. (1994, 2002, 2003, 2007, 2008). The general algorithms of these papers have been coded and known deviations from the published algorithms are noted wherever possible.

The user is encouraged to modify model parameters using the input parameter files for the DEM preprocessing and the statistical mapping algorithm.  The modular design also allows for additional functionality to be added, hopefully with minimal effort.  It is hoped this code base allows for a fuller understanding of the impacts sometimes seemingly small methodological choices have on our final gridded estimates.

It is *highly* recommended to read the STIR description paper in GMD (citation to follow).  Also the example tarball at () contains an example input grid, example station data, configuration and parameter files used in the example cases.  These can also then be used as example formats for your own data.

## Installing the code:

This code is written in Matlab and requires Matlab along with the mapping and image processing toolboxes.  The user needs to include the STIR repository directory and all subdirectories in their Matlab path

        addpath(genpath('/path/to/STIR/'))

It has also been tested for GNU Octave compatibility on a Mac running HighSierra OS10.13.6 using an Octave disk image of version 4.4.1 (https://octave-app.org/Download.html).  Octave is a free alternative to Matlab with generally good Matlab compatibility.  STIR requires the netcdf, image, and mapping Octave packages to be installed.  See the Octave install readme for more details.

Extensive compatibility testing is not supported by the author(s) currently.

## Development:

STIR uses Git as its version control tool. Further description of git (https://git-scm.com/book/en/v2) and STIR can be found in STIRandGit.md and STIRGitWorkflow.md.

## Examples:

An example case has been developed with example parameter perturbations and output and can be found at (ral.ucar.edu/projects/STIR) including a tutorial guide in docs/exampleReadme.md.

## References:

* Daly, C., R. P. Neilson, and D. L. Phillips, 1994: A Statistical-Topographic Model for Mapping Climatological Precipitation over Mountainous Terrain, J. Appl. Meteor., 33, 140-158.
* Daly, C., W. P. Gibson, G. H. Taylor, G. L. Johnson, and P. Pasteris, 2002: A knowledge-based approach to the statistical mapping of climate. Clim. Res. 22: 99–113, doi: 10.3354/cr022099.
* Daly, C., E. H. Helmer, and M. Quinones, 2003: Mapping the climate of Puerto Rico, Vieques, and Culebra. Int. J. Climatol. 23: 1359–1381, doi:10.1002/joc.937.
* Daly, C., J. W. Smith, J. I. Smith, and R. B. McKane, 2007: High-resolution spatial modeling of daily weather elements for a catchment in the Oregon Cascade Mountains, United States. J. Appl. Meteorol. Climatol., 46, 1565-1586.
* Daly, C., M. Halbleib, J. I. Smith, W. P. Gibson, M. K. Doggett, G. H. Taylor, J. Curtis, and P. A. Pasteris, 2008: Physiographically-sensitive mapping of temperature and precipitation across the conterminous United States. Int. J. Climatol. 28: 2031–2064, doi: 10.1002/joc.1688.


