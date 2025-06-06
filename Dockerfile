# Start from a base image with Flutter which has the version used in this repository
FROM instrumentisto/flutter:latest

WORKDIR /app

# We only need to copy the entrypoint script to the image to run the tests, we dont need to copy the code since we will use bind mounts to make this container have the entire project
COPY coverage.sh /coverage.sh
RUN chmod +x /coverage.sh

# Activate coverage package globally
RUN flutter pub global activate coverage

# Run tests and generate coverage
ENTRYPOINT ["/coverage.sh"]
