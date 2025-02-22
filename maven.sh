 # This can be sourced in gitlab build
 # it recognizes
 # TRACE
 # CI_PROJECT_DIR
 # BUILD_TARGET
 # MAVEN_THREADS
 # MAVEN_PROFILES_OPT
 # SKIP_TESTS
 # SKIP_INTEGRATION_TESTS
 # MAVEN_EXTRA_ARGS
 # TEST_FAILURE_IGNORE
 # SKIP_TESTS_IMPLICIT

JOB_ENV=${JOB_ENV:=job.env}
MAVEN_THREADS=${MAVEN_THREADS:=2}
CI_PROJECT_DIR=${CI_PROJECT_DIR:=$(pwd)}
SKIP_TESTS=${SKIP_TESTS:=false}
SKIP_INTEGRATION_TESTS=${SKIP_INTEGRATION_TESTS:=${SKIP_TESTS}}
BUILD_TARGET=${BUILD_TARGET:=package}
export MAVEN_ARGS=${MAVEN_ARGS:=--no-transfer-progress}
EXIT=${EXIT:=true}

if [ "$TRACE" == 'true' ]; then
 set -x
 env
else
  set +x
fi

_exit() {
   set +x
   echo "exit $1" ;
   if [ "$EXIT" == 'true' ]; then
     exit $1
   fi
}


if [ "$TRACE" == 'true' ]; then echo "check cache size" && du -sh $CI_PROJECT_DIR/.m2/repository || true ; fi
if [ "$TRACE" == 'true' ]; then echo "file number" && (find  $CI_PROJECT_DIR/.m2/repository -type f  || true) | wc -l ; fi
if [ "$TRACE" == 'true' ]; then ls -l */target || true ; fi
echo target $BUILD_TARGET
mvn -ntp -T $MAVEN_THREADS \
      --fail-at-end \
      -U \
      --batch-mode \
      $MAVEN_PROFILES_OPT \
      -DskipTests=$SKIP_TESTS \
      -DskipITs=$SKIP_INTEGRATION_TESTS \
       -Dmaven.test.failure.ignore=true  `: # Just use the result from after_maven.sh` \
       $BUILD_TARGET  ; result=$?
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