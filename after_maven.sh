echo "PROJECT_VERSION="$(mvn  -ntp help:evaluate -Dexpression=project.version -q -DforceStdout) | tee -a job.env
counts=($(for d in `find . -name 'surefire-reports' -print` ; do cat $d/*.txt 2>/dev/null ; done | grep -E "^Tests run:" | awk -F'[, ]+' 'BEGIN {t=0; f=0; e=0; s=0}  {t+=$3; f+=$5; e+=$7; s+=$9} END {print t"\t"f"\t"e"\t"s}'))

echo "JOB_ID_BUILD_STAGE=$CI_JOB_ID" | tee -a job.env
echo "MAVEN_TESTS_RUN=${counts[0]}" | tee -a job.env
echo "MAVEN_TESTS_FAILED=${counts[1]}" | tee -a job.env
echo "MAVEN_TESTS_ERROR=${counts[2]}" | tee -a job.env
echo "MAVEN_TESTS_SKIPPED=${counts[3]}" | tee -a job.env
    
    
# make sure some files exist otherwise 'reports' gets confused
if [ ${counts[0]} -eq 0 ]; then
  echo no tests found. Making empty suites
  mkdir -p a/target/surefire-reports ; echo '<testsuite />' >  a/target/surefire-reports/TEST-empty.xml 
  mkdir -p a/target/failsafe-reports ; echo '<testsuite />' >  a/target/surefire-reports/TEST-empty.xml 
fi

sort -u -o job.env job.env
wc -l job.env

if [ -d target/site ]; then 
  cp -r target/site/* public  
else  
  mkdir -p public 
  date --iso-8601=seconds > public/date  
fi
source job.env
