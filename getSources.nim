# From GitHub API
# Note: In the past, pull requests and issues were more closely aligned than they are now.
# As far as the API is concerned, every pull request is an issue, but not every issue is a pull request.
# This endpoint may also return pull requests in the response. If an issue is a pull request, the object will include a pull_request key.

import httpclient, os
import strutils, json, streams
import github_api/[client, issue, repository]

const
  orgName = "nim-lang"
  repoName = "nim"

# Your access token
#  accessToken = ""
  accessToken = nil
  replacements = [
    (":", "_"),
    (".", "_"),
    ("@", "_"),
    ("/", "_"),
    ("\"", ""),
  ]

var
  gh: GithubApiClient
  resp: Response
  label: string = ""

gh = newGithubApiClient(accessToken)

if paramCount() > 0:
  label = paramStr(1)

var
  i = 1

while true:
  resp = gh.listIssues(orgName, repoName, labels = label, limit = 100, page = i)
  echo resp.status
  i.inc
  if not resp.status.startsWith("200"):
    break

  let issues = parseJson(resp.bodyStream.readAll())
  for item in issues.items:
    if not item.hasKey("pull_request"):
      let title = $item["number"] & " - " & multiReplace($item["title"], replacements)
      let fileName = title & ".nim"
      if not fileExists(fileName):
        let body = item["body"].getStr
        echo title
        let codeStart = body.find("```nim")
        if codeStart > 0:
          let codeFinish = body.find("```", codeStart + 6)
          let code = body[codeStart+6..codeFinish-1]
          let fs = newFileStream(fileName, fmWrite)
          fs.write(code)
          fs.close