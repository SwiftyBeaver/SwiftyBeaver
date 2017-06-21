# use the latest stable Swift 3.1
FROM swift:3.1

WORKDIR /code 

COPY Package.swift /code/
COPY ./Sources /code/Sources
COPY ./Tests /code/Tests

RUN swift --version
RUN swift build
