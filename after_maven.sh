setProperty(){
  if [ ! -e $3 ] ; then
    touch $3
  fi
  awk -v pat="^$1=" -v value="$1=$2" 'BEGIN {found=0; } { if ($0 ~ pat) { found=1; print value; } else print $0; } END { if (! found) print value  }' $3 > $3.tmp
  mv -f $3.tmp $3 >/dev/null
}

setProperty "PROJECT_VERSION" "$(mvn  -ntp help:evaluate -Dexpression=project.version -q -DforceStdout)" job.env
counts=($(for d in `find . -name 'surefire-reports' -print` ; do cat $d/*.txt 2>/dev/null ; done | grep -E "^Tests run:" | awk -F'[, ]+' 'BEGIN {t=0; f=0; e=0; s=0}  {t+=$3; f+=$5; e+=$7; s+=$9} END {print t"\t"f"\t"e"\t"s}'))

setProperty "JOB_ID_BUILD_STAGE" "$CI_JOB_ID" job.env
setProperty "MAVEN_TESTS_RUN" "${counts[0]}" job.env
setProperty "MAVEN_TESTS_FAILED" "${counts[1]}" job.env
setProperty "MAVEN_TESTS_ERROR" "${counts[2]}" job.env
setProperty "MAVEN_TESTS_SKIPPED" "${counts[3]}" job.env
    
    
# make sure some files exist otherwise 'reports' gets confused
if [ ${counts[0]} -eq 0 ]; then
  echo no tests found. Making empty suites
  mkdir -p a/target/surefire-reports ; echo '<testsuite />' >  a/target/surefire-reports/TEST-empty.xml 
  mkdir -p a/target/failsafe-reports ; echo '<testsuite />' >  a/target/surefire-reports/TEST-empty.xml 
fi

wc -l job.env

if [ -d target/site ]; then 
  cp -r target/site/* public  
else  
  mkdir -p public 
  date --iso-8601=seconds > public/date  
fi
source job.env
