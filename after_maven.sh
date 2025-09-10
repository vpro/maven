#This script can be sourced after running maven
# It will fill a fill and source a file 'job.env'
# It will contain a few new variables

JOB_ENV=${JOB_ENV:=job.env}
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
INPUT_DETERMINE_VERSION=${INPUT_DETERMINE_VERSION:='true'}
INPUT_COVERAGE=${INPUT_COVERAGE:='true'}
INPUT_PUBLIC=${INPUT_PUBLIC:='true'}

if [ "$JOB_ENV" = "NO" ] ; then
    has_job_env=false
    JOB_ENV=$(mktemp);
    #echo "No JOB_ENV Using $JOB_ENV"
else
    has_job_env=true
fi


setProperty(){
  if [ ! -e "$3" ] ; then
    touch "$3"
  fi
  awk -v pat="^$1=" -v value="$1=$2" 'BEGIN {found=0; } { if ($0 ~ pat) { found=1; print value; } else print $0; } END { if (! found) print value  }' "$3" > "$3".tmp
  mv -f "$3".tmp "$3" >/dev/null
}

if [ "$INPUT_DETERMINE_VERSION" = 'true' ] ; then
    setProperty "PROJECT_VERSION" "$(mvn  -ntp help:evaluate -Dexpression=project.version -q -DforceStdout)" "$JOB_ENV"
fi

mapfile -t counts < <(find . \( -name 'surefire-reports' -o -name 'failsafe-reports' \) -exec find \{\} -name '*.xml' -print0   \; | xargs -0 xsltproc "${SCRIPT_DIR}"/count.xslt | awk -F'[, ]+' 'BEGIN {t=0; f=0; e=0; s=0}  {t+=$3; f+=$5; e+=$7; s+=$9} END {print t"\n"f"\n"e"\n"s}' )

setProperty "JOB_ID_BUILD_STAGE" "$CI_JOB_ID" "$JOB_ENV"
setProperty "MAVEN_TESTS_RUN" "${counts[0]}" "$JOB_ENV"
setProperty "MAVEN_TESTS_FAILED" "${counts[1]}" "$JOB_ENV"
setProperty "MAVEN_TESTS_ERROR" "${counts[2]}" "$JOB_ENV"
setProperty "MAVEN_TESTS_SKIPPED" "${counts[3]}" "$JOB_ENV"
setProperty "SKIP_TESTS" "${SKIP_TESTS}" "$JOB_ENV"
setProperty "SKIP_TESTS_IMPLICIT" "${SKIP_TESTS_IMPLICIT}" "$JOB_ENV"




# make sure some files exist otherwise 'reports' gets confused
if [ "${counts[0]}" -eq 0 ]; then
  echo no tests found. Making empty suites
  mkdir -p empty/target/surefire-reports ; echo '<testsuite />' >  empty/target/surefire-reports/TEST-empty.xml
  mkdir -p empty/target/failsafe-reports ; echo '<testsuite />' >  empty/target/surefire-reports/TEST-empty.xml
fi

if $has_job_env ; then
    wc -l "$JOB_ENV"
fi

if [ "$INPUT_INPUT" = "true" ] ; then
   if [ -d target/site ]; then
      cp -r target/site/* public
   else
      mkdir -p public
      date --iso-8601=seconds > public/date
   fi
fi

# shellcheck disable=SC1090
source "$JOB_ENV"


if [ "$INPUT_COVERAGE" = "true" ] ; then
  if find . -name jacoco.xml | grep -q .; then
    echo "Determining coverage"
    for j in `find . -name jacoco.xml`; do
      xsltproc --novalid  "${SCRIPT_DIR}"/jacoco.xslt $j
    done
  else
    echo "No jacoco.xml found"
  fi
else
   echo "Skipping coverage"
fi

cat "$JOB_ENV" | grep -v '=$'

if ! $has_job_env; then
    rm $JOB_ENV
fi

echo "failures and errors"
find . \( -name 'surefire-reports' -o -name 'failsafe-reports' \) -exec find \{\} -name '*.xml' -print0   \; |  xargs -0 stat -c"%Y %y %n" | sort -rn | awk '{print $5}' | xargs  xsltproc "${SCRIPT_DIR}"/failures_and_errors.xslt

