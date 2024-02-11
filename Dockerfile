FROM --platform=linux/amd64 node:14

# Set the working directory in the container to /app
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install the application's dependencies inside the Docker image
RUN npm install

# Copy the rest of the application's code to the working directory
COPY . .

# Expose port 8080 for the application.
EXPOSE 8080

# Define the command to run the application
CMD [ "npm", "start" ]