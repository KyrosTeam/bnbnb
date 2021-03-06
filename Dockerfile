
### STAGE 1: Build ###

# We label our stage as ‘builder’
FROM jenkins/jenkins:lts

USER root

COPY package.json package-lock.json ./

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

RUN apt-get install -y nodejs
## Storing node modules on a separate layer will prevent unnecessary npm installs at each build

RUN npm ci && mkdir /ng-app && mv ./node_modules ./ng-app

WORKDIR /ng-app

COPY . .

## Build the angular app in production mode and store the artifacts in dist folder

RUN npm run ng build -- --prod --output-path=dist


### STAGE 2: Setup ###

FROM nginx:1.14.1-alpine

COPY nginx.conf /etc/nginx/nginx.conf

WORKDIR /usr/share/nginx/html

## From ‘builder’ stage copy over the artifacts in dist folder to default nginx public 

COPY . .

USER jenkins
