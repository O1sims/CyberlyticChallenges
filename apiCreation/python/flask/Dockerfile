FROM python:3.6

# Set up apt-get
RUN apt-get -qq update

# Download Python framework and dependencies
RUN apt-get install -qq -y build-essential libffi-dev python3-dev

# Set up the Eve framework
RUN mkdir /app
WORKDIR /app
COPY requirements.txt /app
RUN pip install -r requirements.txt

# Expose ports
EXPOSE 5000
