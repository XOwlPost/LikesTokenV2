# Start from the Node.js slim LTS image for a smaller, more secure base image
FROM node:16-bullseye-slim as build

# Set the working directory inside the container to /app
WORKDIR /app

# Copy package.json and yarn.lock to /app
COPY package.json yarn.lock ./

# Install git and other dependencies
RUN apt-get update && apt-get install -y git

# Install dependencies using yarn
RUN yarn install --cache-clean

# Copy the rest of the project into /app
COPY . .

# Yarn build
RUN yarn build

# Compile using Hardhat
RUN npx hardhat compile

# Rest of the build stage...

# The final stage, which will be the image used in production
FROM node:16-bullseye-slim as release

# Set the working directory inside the container to /app
WORKDIR /app

# Copy over the built application from the build stage
COPY --from=build /app /app

# Add a user with a home directory and no password set
RUN adduser --home /home/appuser --disabled-password --gecos '' appuser \
    && chown -R appuser:appuser /app

# Use the user 'appuser' to run the app
USER appuser

# Expose the port that your dApp or scripts might use
EXPOSE 3000

# Set any environment variables you might need
ENV NODE_ENV=production

# Set the entry point script as the default command
CMD ["/app/entrypoint.sh"]
