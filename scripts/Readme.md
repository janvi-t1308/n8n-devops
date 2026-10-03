#PRODUCTION-READY N8N DEPLOYMENT WITH DOCKER COMPOSE 

##Project Overview-

This project demostrates, how to deploy and manage **n8n** in a production-like environment using **docker-compose** and **postgresql**.
The primary goal of this project is not simply to containerize the application, but to implement operational practices used in real-world Devops environment. These includes deployment automation, health checks, rollback mechanism, backup and restore procedures, and modular bash Scripting.
This project is designed to simulate the deployment life cycle of a production application running on AWS EC2 instance while following engineering practices such as modular scripting, error handling and disaster recovery.

##Features-

1. Docker compose based application deployment
2. PostgreSQL as backend database
3. Persistent docker volumes
4. Automated deployment using Bash
5. Docker compose validation
6. Application health checks
7. Automatic rollback on deployment failure
8. PostgreSQL backup and restore
9. Application volume backup and restore
10. Modular shell scripting following the single responsibility Principle
11. GitHub Actions CI/CD integration