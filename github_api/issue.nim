import httpclient, ospaths, json
import client, repository, pullrequest

type
    Issue* = ref object
        url*: string
        repository_url*: string
        labels_url*: string
        comments_url*: string
        events_url*: string
        html_url*: string
        id*: int
        number*: int
        title*: string
        user*: User
        labels*: string
        state*: string
        locked*: bool
        assignee*: User
        assignees*: string
        milestone*: string
        comments*: int
        created_at*: string
        updated_at*: string
        closed_at*: string
        author_association*: string
        pull_request*: PullRequest
        body*: string
        closed_by*: string

proc listIssues*(
    client: GithubApiClient,
    owner: string = nil,
    repo: string = nil,
    filter: string = nil,
    state: string = nil,
    labels: string = nil,
    sort: string = nil,
    direction: string = nil,
    since: string = nil,
    limit: int = 100,
    page: int = 1): Response =

    var data = %*{
        "filter": filter,
        "state": state,
        "labels": labels,
        "sort": sort,
        "direction": direction,
        "since": since,
        "per_page": limit,
        "page": page
    }
    var path = "repos" / owner / repo / "/issues"
    client.request(path, query = data)
