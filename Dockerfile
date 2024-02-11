FROM python:3.8  # Or another suitable base image

WORKDIR /app

# This is where the magic happens - We'll inject libraries here
COPY requirements.txt ./ 
RUN pip install -r requirements.txt -t ./python

# Zip the installed dependencies for the layer
RUN zip -r layer.zip python
