$(document).ready(->
    $newCommit = $ "<li>new commit</li>"
    $newCommit.addClass('commit').css('display', 'none')
    $('#commits').prepend($newCommit)
    $newCommit.fadeIn 'slow'
)
