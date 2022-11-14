FROM python:3.8-alpine
LABEL project="chaosmonkey"

WORKDIR /app
RUN adduser --system --no-create-home chaosmonkey

COPY requirements.txt ./

# Install required packages
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .

USER chaosmonkey

CMD [ "python3", "./main.py" ]