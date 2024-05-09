provider "aws" {
  region     = "us-east-1"
  access_key = "" #Your AccessKey
  secret_key = "" #Your Secretkey
}

resource "aws_sns_topic" "billing_alert_aws" {
  name = "AWS_billing_alert"
}

resource "aws_cloudwatch_metric_alarm" "cost_alarm" {
  alarm_name          = "BillingAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 21600
  statistic           = "Maximum"
  threshold           = 5.0  # Set your threshold value here
  alarm_description   = "This alarm is triggered when estimated charges exceed $100"
  
  dimensions = {
    Currency = "USD"
  }

  alarm_actions = [
    aws_lambda_function.sns_to_slack.arn,
  ]
}

resource "aws_iam_role" "lambda_exec" {
  name               = "lambda-exec-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_lambda_function" "sns_to_slack" {
  filename      = "./lambda_function.zip"
  function_name = "SnsToSlack"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  environment {
    variables = {
      SLACK_WEBHOOK_URL = "https://hooks.slack.com/services/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" #Your Slack URL
    }
  }
}

resource "aws_lambda_permission" "sns_to_slack_permission" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sns_to_slack.arn
  principal     = "sns.amazonaws.com"

  source_arn = aws_sns_topic.billing_alert_aws.arn
}
