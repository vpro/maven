#This script can be sourced after running maven
# It will fill a fill and source a file 'job.env'
# It will contain a few new variables

if [ -z "$JOB_ENV" ]; then
  echo "JOB_ENV not set, taking 'job.env'"
  JOB_ENV=job.env
fi


setProperty(){
  if [ ! -e $3 ] ; then
    touch $3
  fi
  awk -v pat="^$1=" -v value="$1=$2" 'BEGIN {found=0; } { if ($0 ~ pat) { found=1; print value; } else print $0; } END { if (! found) print value  }' $3 > $3.tmp
  mv -f $3.tmp $3 >/dev/null
}

setProperty "PROJECT_VERSION" "$(mvn  -ntp help:evaluate -Dexpression=project.version -q -DforceStdout)" $JOB_ENV

mapfile -t counts < <(find . -name 'surefire-reports' -exec find \{\} -name '*.txt' -print0   \; | xargs -0 cat 2>/dev/null  | grep -E "^Tests run:" | awk -F'[, ]+' 'BEGIN {t=0; f=0; e=0; s=0}  {t+=$3; f+=$5; e+=$7; s+=$9} END {print t"\n"f"\n"e"\n"s}' )

setProperty "JOB_ID_BUILD_STAGE" "$CI_JOB_ID" $JOB_ENV
setProperty "MAVEN_TESTS_RUN" "${counts[0]}" $JOB_ENV
setProperty "MAVEN_TESTS_FAILED" "${counts[1]}" $JOB_ENV
setProperty "MAVEN_TESTS_ERROR" "${counts[2]}" $JOB_ENV
setProperty "MAVEN_TESTS_SKIPPED" "${counts[3]}" job$JOB_ENV
    
    
# make sure some files exist otherwise 'reports' gets confused
if [ ${counts[0]} -eq 0 ]; then
  echo no tests found. Making empty suites
  mkdir -p empty/target/surefire-reports ; echo '<testsuite />' >  empty/target/surefire-reports/TEST-empty.xml 
  mkdir -p empty/target/failsafe-reports ; echo '<testsuite />' >  empty/target/surefire-reports/TEST-empty.xml 
fi

wc -l $JOB_ENV

if [ -d target/site ]; then 
  cp -r target/site/* public  
else  
  mkdir -p public 
  date --iso-8601=seconds > public/date  
fi
source "$JOB_ENV"

