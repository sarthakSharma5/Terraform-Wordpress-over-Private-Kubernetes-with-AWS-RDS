provider "aws" {
    region = "ap-south-1"
    profile = "<IAM user>"
}

# security group for MySQL DB
resource "aws_security_group" "task5-sg-db" {
  name = "SG-Database"
  vpc_id = "<VPC-ID provided by AWS>"                      // use VPC-ID assigned by AWS

  ingress {
    description = "MySQL"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "task5-sg-db"
  }
}

# launching a DB_Instance for MySQL RDS
resource "aws_db_instance" "task6-MySQL-DB" {
    storage_type = "gp2"
    engine = "mysql"
    engine_version = "5.7.30"
    identifier = "mysql"
    instance_class = "db.t2.micro"
    allocated_storage = 20
    name = "WordPressDB"                               // database name
    username = "admin"                                 // database username
    password = "rootdbsarthak"                         // database password
    parameter_group_name = "default.mysql5.7"
    auto_minor_version_upgrade = true
    publicly_accessible = true
    port = "3306"
    vpc_security_group_ids= [
        aws_security_group.task5-sg-db.id,
    ]
    final_snapshot_identifier = false
    skip_final_snapshot = true
}


provider "kubernetes" {
    config_context_cluster = "minikube"
}

resource "kubernetes_service" "task6-service" {
    metadata {
        name = "task6-wp-service"
    }
    spec {
        selector = {
            app = "webapp"
        }
        port {
            node_port = 31180
            port = 80
            target_port = 80
        }
        type = "NodePort"
    }
}

resource "kubernetes_deployment" "task6-Wordpress" {
    metadata {
        name = "task6-wp-deploy"
        labels = {
            app = "webapp"
        }
    }
    spec {
        replicas = 1
        selector {
            match_labels = {
                app = "webapp"
            }
        }
        template {
            metadata {
                labels = {
                    app = "webapp"
                }
            }
            spec {
                container {
                image = "wordpress:latest"
                name  = "task6-wp-cont"
                    port {
                        container_port = 80
                    }
                }
            }
        }
    } 
}

output "task6-db-endpoint" {
    value = aws_db_instance.task6-MySQL-DB.endpoint
}
