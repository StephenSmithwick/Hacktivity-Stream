commits = [
    {author: 'Ren', date: 'just now', message: 'commit message', svn: 'svn: 9999'},
    {author: 'Stephen', date: 'just now', message: 'commit message', svn: 'svn: 10000'}
]


$(document).ready(->
    consumeNewCommit()
)


consumeNewCommit = () ->
    if commits.length === 0
        return

    commit = commits.shift()
    addCommit(commit, consumeNewCommit)


addCommit = (commit, onComplete) ->
    $newCommit = $("<li></li>").addClass('commit')
    $author = $("<div>#{commit.author}</div>").addClass('author')
    $date = $("<div>#{commit.date}</div>").addClass("date")
    $message = $("<div>#{commit.message}</div>").addClass("message")
    $svn = $("<div>#{commit.svn}</div>").addClass("svn")

    $newCommit.append($author)
    $newCommit.append($date)
    $newCommit.append($message)
    $newCommit.append($svn)

    $('#commits').prepend($newCommit)
    height = $newCommit.outerHeight()
    $newCommit.css('margin-top', -height)
    $newCommit.animate {'margin-top': 0}, {duration: 1000, complete: onComplete}

    removeBottomCommit


removeBottomCommit = () ->
    $('#commits .commit:last-child').remove()
