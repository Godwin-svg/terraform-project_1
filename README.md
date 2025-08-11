
---

# Terraform Web Application Infrastructure 

## **Scenario**

This infrastructure deploys a web application on AWS, with a focus on **CPU utilization management** using CloudWatch alarms and an Auto Scaling Group.

Key design points:

* **Auto Scaling Group** (ASG) to automatically scale EC2 instances up or down based on CPU usage.
* **Security Groups** configured to allow only traffic from the Application Load Balancer (ALB) to reach the Apache web server.
* **User data script** (`install_apache.sh`) automatically installs and starts Apache on each EC2 instance.
* ASG configured with a **maximum of 3 instances**, **minimum of 1 instance**, and **desired capacity of 2**.
* **Terraform** used as Infrastructure as Code (IaC) to provision all AWS resources.

---

## **Prerequisites**

Before deploying, ensure you have:

* An **AWS Account**
* A **GitHub repository** for your project
* Cloned the project directory to your local machine
* Basic knowledge of **Terraform** and **AWS CLI**
* AWS credentials configured locally:

  ```bash
  aws configure
  ```

---

## **Step 1: Project Structure**

The Terraform configuration files (`.tf`) include:

| File                 | Purpose                                             |
| -------------------- | --------------------------------------------------- |
| `provider.tf`        | AWS provider configuration                          |
| `variables.tf`       | Input variable definitions                          |
| `vpc.tf`             | VPC and subnet creation                             |
| `alb.tf`             | Application Load Balancer configuration             |
| `asg.tf`             | Auto Scaling Group, policies, and CloudWatch alarms |
| `launch_template.tf` | EC2 launch template configuration                   |
| `security_group.tf`  | Security group rules                                |
| `install_apache.sh`  | Apache installation script                          |

---

## **Step 2: Resource Overview**

* **`provider.tf`** – Specifies AWS provider and region
* **`variables.tf`** – Defines all required input variables such as CIDR blocks, AMI, and project name
* **`security_group.tf`** – Contains inbound/outbound rules for ALB and EC2 instances
* **`alb.tf`** – Configures the ALB, target group, and listener
* **`launch_template.tf`** – Launch template for EC2 instances with Apache installed via user data script
* **`install_apache.sh`** – Installs and starts Apache web server with a default HTML welcome page
* **`asg.tf`** – Creates Auto Scaling Group with scaling policies and CloudWatch CPU utilization alarms

---

## **Step 3: Deploying to AWS**

Deployment was carried out **in phases** for each resource to simplify troubleshooting.

**1. Format the code:**

```bash
terraform fmt
```

**2. Preview changes (plan):**

```bash
terraform plan
```

**3. Apply changes (deploy):**

```bash
terraform apply
```

**4. Destroy infrastructure:**

```bash
terraform destroy
```

---

## **Features**

✅ Infrastructure as Code with Terraform
✅ Highly available architecture using ALB and multiple subnets
✅ Automatic scaling based on CPU load
✅ Secure traffic flow restricted via Security Groups
✅ Automated Apache installation on launch

---





