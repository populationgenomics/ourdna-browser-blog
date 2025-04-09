FROM python:3.12-alpine

# Create app user and group
RUN addgroup -S app && adduser -S app -G app

RUN mkdir /app && chown app:app /app

USER app
WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Copy files
COPY --chown=app:app auth/auth-requirements.txt /app/auth-requirements.txt
COPY --chown=app:app auth/auth.py /app/auth.py

# Install dependencies
RUN pip install --no-cache-dir -r auth-requirements.txt

# Run
CMD ["gunicorn", \
  "--bind", ":8000", \
  "--log-file", "-", \
  "--workers", "2", "--threads", "4", "--worker-class", "gthread", \
  "--worker-tmp-dir", "/dev/shm", \
  "auth:app"]