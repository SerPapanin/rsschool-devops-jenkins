FROM python:3.9-slim-buster
WORKDIR /app
COPY app/ .
RUN pip install --no-cache-dir -r requirements.txt

# Set environment variable for Flask
ENV FLASK_APP=main.py

# Expose the port
EXPOSE 8080

# Run Flask
CMD ["flask", "run", "--host=0.0.0.0", "--port=8080"]
