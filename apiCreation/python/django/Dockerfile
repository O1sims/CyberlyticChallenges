FROM python:3.6

ENV PYTHONUNBUFFERED 1

# Set up apt-get
RUN apt-get -qq update

# Download Python framework and dependencies
RUN apt-get install -qq -y build-essential libffi-dev python3-dev

# Set up the Django framework
RUN mkdir /code
WORKDIR /code
ADD requirements.txt /code/
RUN pip install -r requirements.txt

# Expose ports
EXPOSE 5000
