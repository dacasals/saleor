FROM python:3.5
ENV PYTHONUNBUFFERED 1
RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
RUN \
  apt-get -y update && \
  apt-get install -y gettext curl wget nodejs  nodejs-legacy && \
  apt-get clean 
RUN npm i webpack -g
npm i yarn -g
ADD requirements.txt /app/
ADD package.json /app/
RUN pip install -r /app/requirements.txt
ADD . /app
WORKDIR /app
RUN yarn run build-assets
EXPOSE 8000
ENV PORT 8000

RUN mkdir -p /root/.pip/
RUN /bin/bash -c 'echo "[global]" > ~/.pip/pip.conf'
RUN /bin/bash -c 'echo "timeout = 120" >> ~/.pip/pip.conf'
RUN /bin/bash -c 'echo "index = http://nexus.prod.uci.cu/repository/pypi-all/pypi" >> ~/.pip/pip.conf'
RUN /bin/bash -c 'echo "index-url = http://nexus.prod.uci.cu/repository/pypi-all/simple" >> ~/.pip/pip.conf'
RUN /bin/bash -c 'echo "[install]" >> ~/.pip/pip.conf'
RUN /bin/bash -c 'echo "trusted-host = nexus.prod.uci.cu" >> ~/.pip/pip.conf'

CMD ["uwsgi", "/app/saleor/wsgi/uwsgi.ini"]
