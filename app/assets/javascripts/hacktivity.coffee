$(document).ready(->
    $newCommit = $("<li>new commit</li>")
    $newCommit.addClass('commit')
    $('#commits').prepend($newCommit)
);
