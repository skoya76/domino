
import slackweb
import sys


slack = slackweb.Slack(url="https://hooks.slack.com/services/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") #塩崎功也@分散システム研究室
slack.notify(text=sys.argv[1])