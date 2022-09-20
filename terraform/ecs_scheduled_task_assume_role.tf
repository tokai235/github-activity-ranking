data "aws_iam_policy_document" "ecs_scheduled_task_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["events.amazonaws.com"]
      type        = "Service"
    }
  }
}

# see: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/CWE_IAM_role.html
data "aws_iam_policy_document" "ecs_scheduled_task_cloudwatch_policy" {
  statement {
    effect    = "Allow"
    actions   = ["ecs:RunTask"]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_scheduled_task_role" {
  name               = "ecs-scheduled-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_scheduled_task_assume_role_policy.json
}

# AWS 公式で policy を提供してくれてないのでインラインでアタッチ
resource "aws_iam_role_policy" "ecs_scheduled_task_role_policy" {
  name   = "ecs-events-run-task-with-any-role"
  role   = aws_iam_role.ecs_scheduled_task_role.id
  policy = data.aws_iam_policy_document.ecs_scheduled_task_cloudwatch_policy.json
}