echo Now branching
export MAVEN_ARGS=${MAVEN_ARGS:=--no-transfer-progress}
#WARNING: A terminally deprecated method in sun.misc.Unsafe has been called
MAVEN_OPTS="--enable-native-access=ALL-UNNAMED --sun-misc-unsafe-memory-access=allow"


if [ -n "$MAVEN_RELEASE_PROFILES" ]; then
  PROFILES="-P${MAVEN_RELEASE_PROFILES}"
elif [ -n "$MAVEN_PROFILES" ]; then
  PROFILES="-P${MAVEN_PROFILES}"
else
  PROFILES=""
fi

VERSION=`mvn help:evaluate -Dexpression=project.version -q -DforceStdout`
RELEASE_VERSION=`echo $VERSION | sed -r 's/-SNAPSHOT/.0-SNAPSHOT/'`
DEVELOPMENT_VERSION=`echo $VERSION | perl -ne 'print sprintf("%s.%s%s%s", $1,$2+1,$3,$4) if /([0-9]+)\.([0-9]+)([\.-])(.*)/'`
echo "Branching for $RELEASE_VERSION. Development version now $DEVELOPMENT_VERSION"
mvn \
    -ntp -q -U \
    -Dmaven.test.skip=true \
    -DreleaseVersion=${RELEASE_VERSION} \
    -DdevelopmentVersion=${DEVELOPMENT_VERSION} \
    -DpushChanges=false \
    --batch-mode \
    -DupdateBranchVersions=true \
    -DdryRun=$DRY_RUN \
    -Darguments="-DskipTests" \
    $PROFILES \
    release:clean \
    release:branch $MVN_BRANCH_EXTRA_COMMANDS