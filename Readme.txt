 the static website is hosted on.
 http://52.16.171.183

If you need a dns we could use route53 from your aws account, create a A record and that should do.

The corrections on the Ec2 instances are as below.

the static files were missing from www folder on the instance had to clone the submodule
git submodule update --init

Found the submodule repo from
[ec2-user@ip-172-29-33-53 assingment]$ cat .gitmodules 
[submodule "www"]
	path = www
	url = https://github.com/whitesunset/wannacrypt_balance
  
git submodule add https://github.com/whitesunset/wannacrypt_balance www



The Docker file had the following lines missing 

RUN mkdir -p /run/nginx

RUN mkdir /www && \
    chown -R nginx:www /var/lib/nginx && \
    chown -R nginx:www /www && \
    chown -R nginx:www /run/nginx

EXPOSE 80 

/run/nginx was important for nginx process to come live.
EXPOSE 80 helps in exposing the running nginx to the instance outside the container.

Docker image was missing to complete docker run.
sudo docker build -t 'website:01' .

sudo docker run -dit -v /home/ec2-user/assingment/www:/www -p 80:80 website:01
**********************************
Adding Context below for the second part of the question.

I would not be able to provide code for automation but the suggestions are below.

We could use a Jenkins template  to Build and  Deploy on jenkins agent.

Checkout the code 
|
|

Build the code using docker

docker build -t 'image name' .

docker tag "image name" "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPO_NAME}:${tagname}"

docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPO_NAME}:${tagname}'
|
|
|

Deploy the code using one of these
AWS ECS to multiple containers.
Kubernetes Cluster as pods using a manifest file.
Docker Swarm

We could deploy it to multiple Ec2 instances using AutoScaling to scale up and down, but you would be spending more money 
for a small static website, which would be economical on containers deployed on clusters which can be scaled up and down.


Updates from 5th August 2019

- We could also deploy these static files to S3 and create a route53 if you are looking for an easier solution or using ansible.
But looking at the bigger picture is what as a Devops Engineer would be ideal.

But since i had suggested the above method which would prove a good solution for all the microservices especially when the idea is to containerize, its idea you follow a containerized solution like docker, ecs, eks, gke or self managed kubernetes cluster.

Docker has been modified to have each projects deployed by passing a parameter.

Please find attached the manifest file and a jenkins template which shows how we could deploy multiple replicas of an image.

ManifestFile - manifest/nginx.yaml
Jenkinsfile


FYI: Running the manifest on a Kubernetes cluster or Jenkinsfile on your jenkins job wouldnot work since it has many pre-requisites to be completed. The current manifest configuration is for a Kubernetes Cluster installed on AWS.

This is all i could do with the single instance and in terms of test that you have provided.

Reach out to me for explanations.












