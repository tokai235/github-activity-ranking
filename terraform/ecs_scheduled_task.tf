resource "aws_cloudwatch_event_rule" "scheduled_task" {
  name                = var.app_name
  description         = "scheduled task that calculate github activity ranking."
  schedule_expression = "cron(0 8 1 * ? *)" # 1日 AM 08:00 (JST) monthly
  is_enabled          = true
}

resource "aws_cloudwatch_event_target" "scheduled_task_target" {
  rule           = aws_cloudwatch_event_rule.scheduled_task.name
  event_bus_name = aws_cloudwatch_event_rule.scheduled_task.event_bus_name
  target_id      = "${aws_cloudwatch_event_rule.scheduled_task.name}-target"
  arn            = aws_ecs_cluster.cluster.arn
  role_arn = aws_iam_role.ecs_scheduled_task_role.arn

  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.task.arn
    launch_type         = "FARGATE"
    propagate_tags      = "TASK_DEFINITION"

    network_configuration {
      subnets         = [aws_subnet.subnet_public_1c.id]
      security_groups = [aws_security_group.ecs_task_sg.id]
    }
  }
}