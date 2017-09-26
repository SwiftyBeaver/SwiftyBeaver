# use the latest snapshot Swift 4.0
FROM lgaches/docker-swift:swift-4

WORKDIR /code 

COPY Package@swift-4.0.swift /code/Package.swift
COPY ./Sources /code/Sources
COPY ./Tests /code/Tests

RUN swift --version
RUN swift build
