FROM python:3.5
ENV PYTHONUNBUFFERED 1
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
RUN \
  apt-get -y update && \
  apt-get install -y gettext nodejs build-essential yarn && \
  apt-get clean 
RUN npm i webpack -g
ADD requirements.txt /app/
ADD package.json /app/
RUN pip install -r /app/requirements.txt
ADD . /app
WORKDIR /app
#RUN curl -o- -L https://yarnpkg.com/install.sh | bash

RUN export PATH="$HOME/.yarn/bin:$PATH"
RUN yarn -v
RUN yarn add webpack
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
