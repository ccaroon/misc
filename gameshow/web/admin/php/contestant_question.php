<?php
    require_once 'common.php'; signup_user(); 
    

    
    if ($_REQUEST)
    {
        $mode = $_REQUEST['mode'];
        
        if ($mode == 'save')
        {
            _handle_save();
            _handle_show_answers();
        }
        else if ($mode == 'show_answers')
        {
            _handle_show_answers();
        }
        else
        {
            _display_question();
        }
    }
    
    function _handle_save()
    {
        $dbh = get_dbh();
        $answer = $_POST['answer'];

        $sql =<<<EOF
        insert into buzz_in 
        (contestant_id,question_id,buzz_in_date,answer)
        values (?,?,now(),?)
EOF;

        $stmt = $dbh->prepare($sql);
        $data = array($_SESSION['id'], $_REQUEST['q_id'], $answer);
        $dbh->execute($stmt,$data);
    }
    
    function _handle_show_answers()
    {
        $info = contestant_info();
        $dbh  = get_dbh();
        
        $sql =<<<EOF
select * from
buzz_in b,
contestant c
where b.contestant_id = c.id
and b.question_id = $_REQUEST[q_id]
order by b.buzz_in_date
EOF;
        $buzz_q = $dbh->getAll($sql);

        print <<<EOF
        <h1>Answers</h1>
        <h2>$info</h2>
        <hr>
        <table border='1'>
            <tr>
                <th>Name</th>
                <th>Answer</th>
                <th>Score</th>
            </tr>
EOF;
        foreach ($buzz_q as $c)
        {
            $color = "#FFFFFF";
            if ($c->contestant_id == $_SESSION['id'])
            {
                $color = '#CCCCCC';
            }
            
            print <<<EOF
            <tr bgcolor="$color">
                <td>
                    $c->name
                </td>
                <td>
                    $c->answer
                </td>
                <td>
                    $c->score
                </td>
            </tr>
EOF;
        }
        print <<<EOF
        </table>
        <p>
        <hr>
        <a href=''>Next Question</a>
        &nbsp;&nbsp;|&nbsp;&nbsp;
        <a href="?mode=show_answers&q_id=$_REQUEST[q_id]">Refresh</a>
EOF;
    }
    
    function _display_question()
    {
        $question = get_next_question();
        $info     = contestant_info();

        print <<<EOF
<html>
    <h1>Question</h1>
    <h2>$info</h2>
    <p>
    <hr>
    $question->question
    <p>
    <hr>
    <form method="post">
        <input type="hidden" name="mode" value="save">
        <input type="hidden" name="q_id" value="$question->id">
        <b>Your Answer:</b><br>
        <textarea name="answer"></textarea>
        <p>
        <input type="submit" value="BUZZ IN">
    </form>
</html>
EOF;
    }
?>
