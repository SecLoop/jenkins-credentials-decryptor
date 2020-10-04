.PHONY: clean dependencies build test run install github-release github-release-dry-run goreleaser-dry-run smoke-test

clean:
	go clean
	rm -rf bin/ dist/

dependencies:
	go mod download
	go mod tidy
	go mod verify

build: dependencies
	go build -o bin/jenkins-credentials-decryptor cmd/jenkins-credentials-decryptor/main.go

test:
	go test -v ./...

run: clean build
	./bin/jenkins-credentials-decryptor $(arg)

install: clean build
	go install -v ./...

smoke-test: clean build
	./bin/jenkins-credentials-decryptor \
        -m ./test/resources/jenkins_2.141/master.key \
        -s ./test/resources/jenkins_2.141/hudson.util.Secret \
        -c ./test/resources/jenkins_2.141/credentials.xml \
        -o $(OUTPUT_FORMAT)

smoke-test-json: OUTPUT_FORMAT=json
smoke-test-json: smoke-test

smoke-test-text: OUTPUT_FORMAT=text
smoke-test-text: smoke-test

goreleaser-release: clean dependencies
	curl -sL https://git.io/goreleaser | VERSION=v0.137.0 bash

goreleaser-dry-run: clean dependencies
	curl -sL https://git.io/goreleaser | VERSION=v0.137.0 bash -s -- --skip-publish --snapshot --rm-dist

goreleaser-dry-run-local: dependencies
	goreleaser release --skip-publish --snapshot --rm-dist
