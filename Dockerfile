# https://github.com/springernature/pa11y-dashboard
FROM node:5
MAINTAINER Rob Loach <robloach@gmail.com>

# Dependencies
RUN apt-get update -y && apt-get upgrade -y && apt-get install net-tools ssh -y
RUN update-rc.d ssh defaults
RUN service ssh start
RUN sed -i "s|UsePAM yes|UsePAM no|g" /etc/ssh/sshd_config

# Environment variables
ENV NODE_ENV ${NODE_ENV:-production}
ENV PA11Y_VERSION 1.8.2
ENV PA11Y_PORT ${PORT:-4000}
ENV PA11Y_NOINDEX ${PA11Y_NOINDEX:-true}
ENV PA11Y_READONLY ${PA11Y_READONLY:-false}
ENV PA11Y_SITEMESSAGE ${PA11Y_SITEMESSAGE:-"Welcome to pa11y"}
ENV PA11Y_WEBSERVICE_DATABASE ${PA11Y_WEBSERVICE_DATABASE:-mongodb://localhost/pa11y-webservice}
ENV PA11Y_WEBSERVICE_HOST ${PA11Y_WEBSERVICE_HOST:-0.0.0.0}
ENV PA11Y_WEBSERVICE_PORT ${PA11Y_WEBSERVICE_PORT:-3000}
ENV PA11Y_WEBSERVICE_CRON ${PA11Y_WEBSERVICE_CRON:-"0 30 0 * * *"}

# Install PhantomJS
RUN npm install phantomjs-prebuilt@2 -g

# Retrieve the dashboard
RUN git clone https://github.com/springernature/pa11y-dashboard.git && cd pa11y-dashboard && npm i pa11y@git+https://github.com/RobLoach/pa11y.git && npm i pa11y-reporter-1.0-json #patch-1 --save && npm i pa11y-webservice@~1.8 --save && npm i

EXPOSE 4000
EXPOSE 3000
EXPOSE 22

# Set up the startup script.
RUN mkdir /root/.ssh
COPY jenkins.pem.pub /root/.ssh/authorized_keys
COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["sh", "/entrypoint.sh"]