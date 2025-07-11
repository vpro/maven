 # This can be sourced in gitlab build
 # it recognizes
 # TRACE
 # BUILD_TARGET
 # MAVEN_THREADS
 # SKIP_TESTS
 # SKIP_INTEGRATION_TESTS
 # MAVEN_EXTRA_ARGS
 # TEST_FAILURE_IGNORE
 # SKIP_TESTS_IMPLICIT

 # Locally you can test it like so:
 # michiel@mitulo:(REL-8.5-SNAPSHOT,4)~/github/npo-poms/poms-parent-branch$ TRACE=true  ~/github/vpro/maven/maven.sh

JOB_ENV=${JOB_ENV:-job.env}
MAVEN_THREADS=${MAVEN_THREADS:-2}
SKIP_TESTS=${SKIP_TESTS:-false}
SKIP_INTEGRATION_TESTS=${SKIP_INTEGRATION_TESTS:-${SKIP_TESTS}}
BUILD_TARGET=${1:-${BUILD_TARGET:-package}}
export MAVEN_ARGS=${MAVEN_ARGS:=--no-transfer-progress}


OLD_X=${-//[^x]/}
_exit() {
   if [[ -n "$OLD_X" ]]; then set -x; else set +x; fi
   echo "exit $1" ;
   exit $1
}
set +x
if [ "$MAVEN_PROFILES" != "" ] ; then
  PROFILES="-P${MAVEN_PROFILES}"
  echo "Using profiles: $PROFILES"
else
  PROFILES=""
fi

if [ "$TRACE" == 'true' ]; then
  ls -l */target 2>/dev/null || true
  echo "==============REPOSITORY"
  M2_REPO=$(mvn $PROFILES help:evaluate -Dexpression=settings.localRepository -q -DforceStdout)
  echo "Used settings.localRepository: $M2_REPO"
  echo "$(find  $M2_REPO -type f  2>/dev/null | wc -l) files, $(du -sh $M2_REPO /repository 2> /dev/null | awk '{print $1}')"
  echo "==============PROFILES"
  mvn $PROFILES help:all-profiles | tee -a all-profiles.txt | grep -v '^\[' | grep .
  echo "==============EFFECTIVE POM"
  mvn $PROFILES help:effective-pom -q -Doutput=effective-pom.xml ;  wc -l effective-pom.xml
  echo "==============EFFECTIVE SETTINGS"
  mvn $PROFILES help:effective-settings -q -Doutput=effective-settings.xml ; cat effective-settings.xml
  set -x
  env
else
  set +x
fi
echo target $BUILD_TARGET
echo "Threads: $MAVEN_THREADS"

mvn -ntp -T $MAVEN_THREADS \
      --fail-at-end \
      -U \
      --batch-mode \
      -DskipTests=$SKIP_TESTS \
      -DskipITs=$SKIP_INTEGRATION_TESTS \
       -Dmaven.test.failure.ignore=true  `: # Just use the result from after_maven.sh` \
       $PROFILES $BUILD_TARGET  ; result=$?
echo "maven exit code: $result"
"${BASH_SOURCE%/*}/after_maven.sh"
source "$JOB_ENV"
echo "Determining whether build failed fatally"
cat "$JOB_ENV" | grep MAVEN_
if [ "$TEST_FAILURE_IGNORE" != "true" ] && [ "$SKIP_TESTS_IMPLICIT" != "true" ] ; then
   if [ $MAVEN_TESTS_ERROR -ge 1 ]; then echo "Test errors ($MAVEN_TESTS_ERROR). Exit 2"; _exit 2 ; fi
   if [ $MAVEN_TESTS_FAILED -ge 1 ]; then echo "Failed test cases ($MAVEN_TESTS_FAILED). Exit 3";  _exit 3 ; fi
fi
if [[ $result -ne 0 ]]; then echo "Failed build exit $result"; _exit $((100 + $result)) ; fi
_exit 0