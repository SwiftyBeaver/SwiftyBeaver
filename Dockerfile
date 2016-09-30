FROM swiftdocker/swift
# Set Swift Path
# learn more at http://bit.ly/2dEKW7w
ENV PATH /usr/bin:$PATH
RUN swift --version
RUN echo "Run container with --privileged=true to use Swift CLI"
RUN mkdir /app
#COPY . /app
ADD . /app
WORKDIR /app
RUN swift build
RUN swift test
