class Consumer
    constructor: () ->
        @commits = []

    add: (newCommits) ->
        @commits.push commit for commit in newCommits

    consume: () ->
        if @commits.length == 0
           return
        self = this
        addCommitWithAnimation(@commits.shift(), () ->
            self.consume()
        )


addCommit = (commit) ->
    $newCommit = $("<li></li>").addClass('commit')
    $id = $("<p>#{commit.id}</p>").addClass('id')
    $avatar = $("<div><image src='assets/avatar/#{commit.avatar_img}'></image></div>").addClass('avatar')
    $author = $("<div>#{commit.author}</div>").addClass('author')
    $date = $("<div></div>").addClass("date timeago").attr('title', commit.date)
    $date.timeago()
    $message = $("<div>#{commit.message}</div>").addClass("message")
    $svn = $("<div>svn: #{commit.svn || ''}</div>").addClass("svn")

    $newCommit.append($id)
    $newCommit.append($avatar)
    $newCommit.append($author)
    $newCommit.append($date)
    $newCommit.append($message)
    $newCommit.append($svn)
    $('#commits').prepend($newCommit)
    return $newCommit


addCommitWithAnimation = (commit, onComplete) ->
    $newCommit = addCommit(commit)
    height = $newCommit.outerHeight()
    $newCommit.css('margin-top', -height)
    $newCommit.animate {'margin-top': 0}, {duration: 1000, complete: onComplete}


removeBottomCommit = () ->
    $('#commits .commit:last-child').remove()
    
   
consumer = new Consumer

poll = () ->
    lastKnownCommit = $('#commits .commit:first-child .id').text()
    return unless lastKnownCommit
    $.ajax({
        url: '/newcommits',
        data: {last_known_commit: lastKnownCommit},
        dataType: 'json',
        success: (newCommits) ->
            if newCommits.length > 0
                consumer.add newCommits
            consumer.consume()
    })


$(document).ready(->
    $.ajax({
        url: '/commits',
        data: {max: 50},
        dataType: 'json',
        success: (commits) ->
            addCommit(commit) for commit in commits
    })
    setInterval(poll, 5000)
)
