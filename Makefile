RELEASE_TITLE=New Release
RELEASE_MESSAGE=Official Release

# BUILD_EXECUTABLE=bpid-server
# BUILD_DESCRIPTOR=Linux-amd64

# Configure build and coverage flags
# LDFLAGS=-ldflags "-w -s"
# COVERAGEFLAGS=-race -coverprofile=coverage.txt -covermode=atomic -v

# Current git branch
BRANCH=$(shell git rev-parse --abbrev-ref HEAD)

# .PHONY: all test coverage changelog clean build release reqcheck
.PHONY: all changelog clean build release reqcheck

# A plain-old `make` command will run the build process for local executable
all: build

# Tests the project
# test:
# 	env GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go test ./... ${LDFLAGS}

# Tests the project linux-only and upload coverage report
# coverage:
# 	@[ "${CODECOV_TOKEN}" ] && echo "all good" || ( echo "CODECOV_TOKEN is not set"; exit 1 )
# 	if [ -f coverage.txt ] ; then rm coverage.txt ; fi
# 	env GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go test ./... ${LDFLAGS} ${COVERAGEFLAGS}
# 	curl -s https://codecov.io/bash | bash

# Generate changelog
changelog: reqcheck
	@[ "${MVERSION}" ] && echo "Tagging Version ${MVERSION}" || ( echo "MVERSION not specified. 'make build MVERSION=v#.#.#'"; exit 1 )
	git-chglog -o CHANGELOG.md --next-tag ${MVERSION}
	git add CHANGELOG.md
	git commit -m "update changelog"
	git push

# Cleans our project: deletes binaries
clean:
	if [ -f coverage.txt ] ; then rm coverage.txt ; fi
	# if [ -f bin/${BUILD_EXECUTABLE} ] ; then rm bin/${BUILD_EXECUTABLE} ; fi

# Builds the project
build: clean
	# env GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build ${LDFLAGS} -o bin/${BUILD_EXECUTABLE}

# Check our requirements
reqcheck:
	hub version
	git version
	git-chglog -v

# Pushes release ( Requires https://github.com/github/hub )
release: reqcheck build
	@[ "${GITHUB_TOKEN}" ] || ( echo "GITHUB_TOKEN not specified"; exit 1 )
	@[ "${MVERSION}" ] && echo "Releasing Version ${MVERSION}" || ( echo "MVERSION not specified. 'make release MVERSION=v#.#.#'"; exit 1 )
	git pull
	# Create the release branch
	git branch release/${MVERSION}
	git checkout release/${MVERSION}
	git push --set-upstream origin release/${MVERSION}
	# Generate the changelog file
	make changelog
	hub release create \
		-a "bin/${BUILD_EXECUTABLE}#${BUILD_EXECUTABLE} (${BUILD_DESCRIPTOR})" \
		-m "${RELEASE_TITLE} ${MVERSION}" \
		-m "${RELEASE_MESSAGE}" \
		-t release/${MVERSION} \
		${MVERSION}
	git pull
	# Copy changelog
	cp CHANGELOG.md CHANGELOG.md.t
	# Return to originating branch
	git checkout ${BRANCH}
	# Update the changelog from the release branch
	cat CHANGELOG.md.t > CHANGELOG.md
	rm CHANGELOG.md.t
	git add CHANGELOG.md
	git commit -m "update changelog"
	git push -f
