FROM python:3.7-stretch

# all-in one update
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get autoremove --purge -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# create non-priviledged group gapp and user uapp
RUN groupadd -g 61000 gapp \
    && useradd -g 61000 -l -M \
    -s /sbin/nologin -u 61000 uapp

# cp app files
WORKDIR /flask_app

# install app requirements
COPY ./requirements.txt .

# install requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# copy all app files
COPY ./flask_app .

# Add permission to uapp
RUN chown -R uapp:gapp .

# Run script as non-priviledged user
USER uapp

WORKDIR /

# Entrypoint
ENTRYPOINT ["gunicorn", "--log-level", "debug", "--bind", "0.0.0.0:5000", "flask_app.wsgi:app", "--timeout",  "90"]

