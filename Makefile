build:
	docker build -t jenkins-dood .
run:
	docker run -d -v /var/run/docker.sock:/var/run/docker.sock -p 8080:8080 -t jenkins-dood
ssh:
	docker exec -it `docker ps -f ancestor=jenkins-dood -q` bash
init-password:
	docker exec `docker ps -f ancestor=jenkins-dood -q` cat /var/jenkins_home/secrets/initialAdminPassword
