 the static website is hosted on.
 http://{{PROJECT}}.binny.com

The Docker file deploys a static website and would provide an endpoint on the internet.

sudo docker build -t 'website:01' .

sudo docker run -dit -v /home/ec2-user/assingment/www:/www -p 80:80 website:01


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


- We could also deploy these static files to S3 and create a route53 if you are looking for an easier solution or using ansible.
But looking at the bigger picture is what as a Devops Engineer would be ideal.

But since i had suggested the above method which would prove a good solution for all the microservices especially when the idea is to containerize, its ideal for you to follow a containerized solution like docker, ecs, eks, gke or self managed kubernetes cluster.

Docker has been modified to have different front end projects deployed by passing a Project parameter.

Please find attached the manifest file and a jenkins template which shows how we could deploy multiple replicas of an image.

ManifestFile - manifest/nginx.yaml
Jenkinsfile


FYI: Running the manifest on a Kubernetes cluster or Jenkinsfile on your jenkins job wouldnot work since it has many pre-requisites to be completed. The current manifest configuration is for a Kubernetes Cluster installed on AWS.

This is all i could do with the single instance and in terms of test that you have provided.

Reach out to me for explanations.












