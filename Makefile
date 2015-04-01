REPORTER = spec
COFFEE = ./node_modules/.bin/coffee

# document generation options
README = -r README.md
NAME = -n 'McFly: This is heavy...'
TITLE = -t 'Application API'
OUTPUT = -o ./docs
DOC_OPS = $(README) $(NAME) $(TITLE) $(OUTPUT)

# document generation input
SOURCE = ./lib ./test

# generate docs
GENERATE_DOCS = $(DOC_OPS) $(SOURCE)

node_modules:
	npm install

test: node_modules
	@NODE_ENV=test ./node_modules/.bin/mocha --compilers coffee:coffee-script/register --reporter $(REPORTER) \
		--recursive -s 120 $(TEST_OPTS)

coverage: node_modules
	@NODE_ENV=test COVERAGE=yes ./node_modules/.bin/mocha --compilers coffee:coffee-script/register \
		--require test/registerCoverageHandlers.js --recursive --reporter html-cov -s 120 $(TEST_OPTS) \
		> coverage-report.html
	@open coverage-report.html

lint: node_modules
	@COFFEELINT_CONFIG=./test/coffeelint.json ./node_modules/.bin/coffeelint lib

# create the api documentation and open the default browser to display it
docs:
	@./node_modules/.bin/codo $(GENERATE_DOCS)

.PHONY: test coverage lint docs