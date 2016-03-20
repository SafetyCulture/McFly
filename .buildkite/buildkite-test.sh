# .buildkite/buildkite-test.sh

set -e
n 0.10
npm install -g npm@2 # only while 0.10
npm install
npm test