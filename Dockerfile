# Start from the Node.js slim image for a smaller, more secure base image
FROM node:21-bookworm-slim

# Set the working directory inside the container to /app
WORKDIR /app

# Copy package.json and yarn.lock to /app
COPY package.json yarn.lock ./

# Install dependencies using yarn
RUN yarn install --frozen-lockfile && yarn cache clean

# Add a user with a home directory and no password set
RUN adduser --home /home/appuser --disabled-password --gecos '' appuser \
    && chown -R appuser:appuser /app

# Copy the rest of the project into /app
COPY . .

# List the contents of /app during build process
RUN ls /app

# Use the user 'appuser' to run the app
USER appuser

# Expose the port that your dApp or scripts might use
EXPOSE 3000

# Set any environment variables you might need
ENV NODE_ENV=development

# Copy entry point script into the container
COPY entrypoint.sh /app/

# Set the entry point script as the default command
CMD ["/app/entrypoint.sh"]
