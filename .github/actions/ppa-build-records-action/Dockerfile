FROM python:3

ADD entrypoint.py /entrypoint.py

RUN python -m pip install --upgrade pip \
    && python -m pip install launchpadlib

ENTRYPOINT ["python", "entrypoint.py"]
