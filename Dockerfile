ARG swift_version=5.0
FROM swift:$swift_version

WORKDIR /code 

COPY Package.swift /code/Package.swift
COPY ./Sources /code/Sources
COPY ./Tests /code/Tests

RUN swift --version
RUN swift build
