# Start from the Node.js slim image for a smaller, more secure base image
# This is the 'build' stage where you compile/build your application
FROM node:21-bookworm-slim as build

# Set the working directory inside the container to /app
WORKDIR /app

# Copy package.json and yarn.lock to /app
COPY package.json yarn.lock ./

# Install git and other dependencies
RUN apt-get update && apt-get install -y git

# Install dependencies using yarn
RUN yarn install --cache-clean

RUN ls -la /app
RUN ls -la /app/node_modules
RUN ls -la /app/node_modules/.bin

# Yarn build
RUN yarn build

# Copy the rest of the project into /app
COPY . .

# Here you would add your build step, for example:
# RUN npx hardhat compile
RUN npx hardhat compile

# Verify that the build was successful
RUN ls -la /app

# Make sure /app/data is created and populated here
RUN mkdir -p /app/data

# Rest of your Dockerfile...

# The final stage, which will be the image used in production called 'release' stage
# Start from the Node.js slim image again for a smaller, more secure final image
FROM node:21-bookworm-slim as release

# Set the working directory inside the container to /app
WORKDIR /app

# Copy over the built application from the build stage
COPY --from=build /app/data /app

# Add a user with a home directory and no password set
RUN adduser --home /home/appuser --disabled-password --gecos '' appuser \
    && chown -R appuser:appuser /app

# Use the user 'appuser' to run the app
USER appuser

# Expose the port that your dApp or scripts might use
EXPOSE 3000

# Set any environment variables you might need
ENV NODE_ENV=production

# Copy entry point script into the container
COPY --from=build /app/entrypoint.sh /app/

# Set the entry point script as the default command
CMD ["/app/entrypoint.sh"]
