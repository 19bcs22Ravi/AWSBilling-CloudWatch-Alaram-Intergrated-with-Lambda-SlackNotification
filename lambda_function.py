import json
import urllib.request

def lambda_handler(event, context):
    try:
        # Construct generic message to be sent to Slack
        slack_message = {
            "text": "Attention! You've reached your maximum billing threshold amount of 5 USD."
        }

        # Send message to Slack
        try:
            slack_webhook_url = "https://hooks.slack.com/services/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"
            req = urllib.request.Request(slack_webhook_url)
            req.add_header('Content-Type', 'application/json')
            urllib.request.urlopen(req, json.dumps(slack_message).encode('utf-8'))
            return {
                'statusCode': 200,
                'body': json.dumps('Slack notification sent successfully')
            }
        except Exception as e:
            return {
                'statusCode': 500,
                'body': json.dumps(f'Error sending Slack notification: {str(e)}')
            }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }
