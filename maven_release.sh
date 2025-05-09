
JOB_ENV=${JOB_ENV:=job.release.env}
DRY_RUN=${DRY_RUN:=false}
CI_COMMIT_REF_NAME=${CI_COMMIT_REF_NAME:=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)}
export MAVEN_ARGS=${MAVEN_ARGS:=--no-transfer-progress}
if [ "$DRY_RUN" == 'true' ]; then
  echo "Dry run"
fi
set -x
echo Running release for $CI_COMMIT_REF_NAME

mvn --threads 1 \
    -DpushChanges=false \
    --batch-mode \
    -Darguments="-DskipTests"  \
    release:clean \
    release:prepare \
    -DdryRun=$DRY_RUN
cat release.properties
if [[ "$DRY_RUN" == "false" ]] ; then git push --atomic -v --follow-tags;  fi
SCM_TAG=$(awk -F= '$1 == "scm.tag" {print $2}' release.properties)
echo "SCM_TAG=$SCM_TAG (checking out)"
git checkout $SCM_TAG
RELEASE_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
export RELEASE_VERSION
export NEW_TAG="REL-$RELEASE_VERSION"
NEW_TAG_SLUG=$(echo $NEW_TAG | iconv -t ascii//TRANSLIT | sed -E -e 's/[^[:alnum:]]+/-/g' -e 's/^-+|-+$//g' | tr '[:upper:]' '[:lower:]')
export NEW_TAG_SLUG
echo "RELEASE_VERSION=$RELEASE_VERSION, SLUG $NEW_TAG_SLUG"
git checkout "$CI_COMMIT_REF_NAME"
mvn -DdryRun=$DRY_RUN -Darguments="$MAVEN_ARGS -DskipTests" $MAVEN_ARGS $MAVEN_RELEASE_PROFILES  -B release:perform
echo "RELEASE_VERSION="$RELEASE_VERSION | tee -a  ${JOB_ENV}  # RELEASE_VERSION is the version that will be used in deploy stage
echo "PROJECT_VERSION="$RELEASE_VERSION | tee -a  ${JOB_ENV}  # PROJECT_VERSION recognized by kaniko image?
echo "NEW_TAG="$NEW_TAG| tee -a  ${JOB_ENV}  # RELEASE_VERSION is the version that will be used in deploy stage
echo "NEW_TAG_SLUG="$NEW_TAG_SLUG| tee -a  ${JOB_ENV} # RELEASE_VERSION is the version that will be used in deploy stage
echo "New tag $NEW_TAG ($NEW_TAG_SLUG) created"