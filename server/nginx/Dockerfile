FROM nginx:1.28.0-alpine

COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY nginx/proxy_params /etc/nginx/proxy_params
COPY scripts/ /srv/scripts/
RUN chmod -R a-w /srv/scripts
