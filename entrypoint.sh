#!/bin/bash
# Run the deploy script
node scripts/deploy.js

# Keep the container running
tail -f /dev/null

# Use docker run to run the container
$ docker run -it --entrypoint /bin/sh likestoken-image

# Run yarn commands inside the container to install dependencies or check troubleshoot issues
/app # yarn install
/app # yarn check

# Run trivy to scan the image for vulnerabilities
trivy image --severity HIGH,CRITICAL likestoken-image
