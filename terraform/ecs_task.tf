resource "aws_ecs_cluster" "cluster" {
  name = var.app_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster" {
  cluster_name       = aws_ecs_cluster.cluster.name
  capacity_providers = ["FARGATE_SPOT"]

  #安いのでなので全て SPOT にする
  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE_SPOT"
  }
}

resource "aws_ecs_task_definition" "task" {
  family                   = var.app_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  cpu                      = 256
  memory                   = 512
  container_definitions = jsonencode([
    {
      name  = var.app_name
      image = aws_ecr_repository.repo.repository_url
      command = [
        # shell の環境変数の読み込みで ${} を使うと terraform の syntax として解釈されてしまうので ${"$"} を使って $ を文字列として解釈させる
        # "go run cmd/main.go -dbuser=${"$"}{DBUSER}"
        "go run cmd/main.go"
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.app_name}"
          awslogs-region        = "ap-northeast-1"
          awslogs-stream-prefix = "ecs"
        }
      }
      # environment = [
      #   {
      #     name  = "DBHOST"
      #     value = local.reader_db_host
      #   }
      # ]
      # secrets = [
      #   {
      #     name      = "DBUSER"
      #     valueFrom = "${module.app_secrets.arn}:dbuser::${module.app_secrets.version_id}"
      #   }
      # ]
    }
  ])
}