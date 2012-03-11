commits = [
    {author: 'Ren', date: 'just now', message: 'commit message', svn: 'svn: 9999'},
    {author: 'Stephen', date: 'just now', message: 'commit message', svn: 'svn: 10000'}
]


class Consumer
    constructor: () ->
        @commits = []

    add: (newCommits) ->
        @commits.push commit for commit in newCommits

    consume: () ->
        if @commits.length == 0
           return
        self = this
        addCommit(@commits.shift(), () ->
            self.consume()
        )


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

    removeBottomCommit()


removeBottomCommit = () ->
    $('#commits .commit:last-child').remove()

consumer = new Consumer

poll = () ->
    last_known_commit = $('#commits .commit:first-child .id').text()
    $.ajax({
        url: '/newcommits',
        data: {last_known_commit: last_known_commit},
        dataType: 'json',
        success: (newCommits) ->
            if newCommits.length > 0
                consumer.add newCommits
            consumer.consume()
    })


$(document).ready(->
    setInterval(poll, 3000)
)
