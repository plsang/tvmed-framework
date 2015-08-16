# Written by Duy Le - ledduy@ieee.org
# Last update Jun 26, 2012
#!/bin/sh
# Force to use shell sh. Note that #$ is SGE command
#$ -S /bin/sh
# Force to limit hosts running jobs
#$ -q all.q@@bc3hosts,all.q@@bc4hosts
# Log starting time
date 
# for opencv shared lib
export LD_LIBRARY_PATH=/net/per610a/export/das11f/plsang/usr/lib:/net/per900a/raid0/plsang/usr.local/lib64:/net/per900a/raid0/plsang/usr.local/lib:/net/per900a/raid0/plsang/software/openmpi-1.6.5/release-shared/lib:/usr/local/lib:$LD_LIBRARY_PATH
# Log info of the job to output file  *** CHANGED ***
echo [$HOSTNAME] [$JOB_ID] [matlab -nodisplay -r "idensetraj_encode('$1', '$2', $3, $4)"]
# change to the code dir  --> NEW!!! *** CHANGED ***
cd /net/per610a/export/das11f/plsang/codes/tvmed-framework-v2.1-med14ps
# Log info of current dir 

LD_PRELOAD="/net/per610a/export/das11f/plsang/usr/lib64/libstdc++.so:/net/per610a/export/das11f/plsang/usr/lib64/libgcc_s.so.1" matlab -nojvm -nodisplay -r "idensetraj_encode('$1', '$2', $3, $4)"
# Log ending time
date

