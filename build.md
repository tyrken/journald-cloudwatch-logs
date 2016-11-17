# Building Linux binary from source on a Mac

1. Install Docker for Mac
1. Clone the repo
1. Run `docker run --rm -v "$PWD":/usr/src/journald-cloudwatch-logs -w /usr/src/journald-cloudwatch-logs -e GOPATH=/usr golang:1.7 sh -c "apt-get update && apt-get install -y libsystemd-journal-dev && go build -v"`
