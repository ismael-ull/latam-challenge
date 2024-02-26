# Use the official Python image as the base image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the Python requirements file to the container
COPY requirements.txt .

# Install the Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the Python application code to the container
COPY lc-api.py .

# Expose the port that the application will listen on
EXPOSE 8080

# Run the Python application
CMD ["python", "lc-api.py"]
