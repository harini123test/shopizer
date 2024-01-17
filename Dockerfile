FROM node:21.6 as builder
ENV NODE_ENV production
RUN apt-get update && \
    apt-get install -y git && \
    apt-get install -y awscli
RUN mkdir -p ~/.aws/
COPY .aws /root/.aws/
RUN git config --global credential.helper '!aws codecommit credential-helper --profile  CodeAccess $@'
RUN git config --global credential.UseHttpPath true

RUN npm install -g yarn
WORKDIR /app


COPY package.json .
COPY yarn.lock .
# Copy aws config file from workspace to workdirectory






# Accessing csw code commit for securin-ai





RUN yarn install --production

# Reverting csw code commit access
RUN git config --global --unset credential.helper
RUN git config --global --unset credential.UseHttpPath

# Copy app files
COPY . .
# Build the app
RUN yarn build

# Bundle static assets with nginx
FROM nginx:1.21.0-alpine as production
ENV NODE_ENV production
#provide owner permission
RUN mkdir -p /usr/share/nginx/html/
RUN chown nginx:nginx /usr/share/nginx/html/*
# Copy built assets from builder
COPY --from=builder /app/build /usr/share/nginx/html
#provide read and write permission
RUN chmod -R 755 /usr/share/nginx/html/
# Add your nginx.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf
# Expose port
EXPOSE 8089
# Start nginx
CMD ["nginx", "-g", "daemon off;"]
