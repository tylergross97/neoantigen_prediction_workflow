FROM python:3.9-slim

# Set work directory
WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . /app

CMD ["/bin/bash"]