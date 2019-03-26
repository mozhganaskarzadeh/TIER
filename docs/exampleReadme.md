## STIR tutorial and example cases

An example domain over the Sierra Nevada along the west coast of USA is provided at (web link TBD).  This example includes configuration and parameter files, the raw domain file, input station data files, and several reference output files for comparisons to make sure STIR is functioning on the users system.

The configuration files will need to be updated for the user defined paths, file names, etc.  The parameter files include default values for this case.  Suggested changes to the parameter files are made in several places in this readme.

To run the example we assume STIR is installed on your system (e.g. [STIR for Octave](octaveInstallReadme.md)).  

### STIR topographic preprocessing

Once you have the example tarball downloaded and unpacked using tar (e.g. `tar -xvf stirExample.tgz`), set the preprocessing configuration variables in `stirPreprocessControl.txt` to the appropirate paths and file names. See the [Config readme](configReadme.md) for details.
It is suggested that you set the output grid name to something different than the reference output grid file provided.
 
Then the run stirPreprocessing.m in Matlab or Octave.  The preprocessing script will use `stirPreprocessParameters.txt` to define user specified values.  If any parameters do not exist in the parameter file, default values are used (set in `preprocess/initPreprocessParameters.m`).

The script will print various diagnostics and will generate the output grid file specified in the preprocessing control file.
Once the preprocessing is finished a brief comparison between your and the reference processed grid file is suggested to make sure the various fields are the same.  A program like ncview (http://meteora.ucsd.edu/~pierce/ncview_home_page.html) can be used for this.


### STIR Model

Once the preprocessing is finished, set the configuration variables in `stirControl.txt` to the appropriate paths and files.  See the [Config readme](configReadme.md) for details.
The STIR model can now be run with stirDriver.m in Matlab or Octave.  All three variables can be interpolated, precip, tmax, and tmin.
The `stirParameter.txt` file will be used to define the STIR model parameter values.  Again, if any parameters do not exist in this parameter file, default values are used (`stirModel/initParameters.m`).
Again, various diagnostics will print while the model is running.  The output file will be generated at the user specified location and name.  It is suggested to make sure the output name is different from the provided reference output files.
It is also suggested to note which variable is interpolated (e.g. have precip, tmax, tmin) in the output file name.

Once the STIR model is complete, the user is encouraged to compare their output with the reference files to see if the reference output is reproducible.


## STIR Parameter Variations

There are many methodological decisions made when developing a spatial map of precipitation.  Here we explore a few parameters in the STIR model only to identify changes in the final estimated values and the corresponding uncertainty.

Note that the preprocessing parameters will also impact the final result through changes in the definition of facets, and changes in the other knowledge-based geophysical attributes.  The user is encouraged to explore those parameters as well.

### First
For precipitation, modify the `minSlope` parameter from 0.25 to 0.0.

### Second
For precipitation, modify the `coastalExp` parameter from 0.75 to 0.5.

### Third
For tmin, modify the `maxSlopeLower` parameter from 20 to 10.
