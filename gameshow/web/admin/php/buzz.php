<?php
    require_once 'common.php'; signup_user(); 
   
    if ($_REQUEST)
    {
        $mode = $_REQUEST['mode'];
        
        if ($mode == 'save')
        {
            _handle_save();
            _handle_show_buzz();
        }
        else if ($mode == 'refresh')
        {
            _handle_show_buzz();
        }
        else
        {
            _handle_show_buzz();
        }
    }
    
    function _handle_save()
    {
        $dbh = get_dbh();
        
        $q_id   = 0;
        $answer = 'none';//$_POST['answer'];

        $sql =<<<EOF
        insert into buzz_in 
        (contestant_id,question_id,buzz_in_date,answer)
        values (?,?,now(),?)
EOF;

        $stmt = $dbh->prepare($sql);
        $data = array($_SESSION['id'], $q_id, $answer);
        $dbh->execute($stmt,$data);
    }
   
    function _handle_show_buzz()
    {
        $info = contestant_info();
        $dbh  = get_dbh();
        
        $sql =<<<EOF
select * from
buzz_in b,
contestant c
where b.contestant_id = c.id
order by b.buzz_in_date
EOF;
        $buzz_q = $dbh->getAll($sql);

        print <<<EOF
        <div align="center">
        <h1>$info</h1>
        <hr>
        <table border='1' width="50%">
            <tr>
                <th bgcolor="#CCCCCC">Name</th>
                <th bgcolor="#CCCCCC">Score</th>
            </tr>
EOF;
        foreach ($buzz_q as $c)
        {
            $color = "white";
            if ($c->contestant_id == $_SESSION['id'])
            {
                $color = 'lightgreen';
            }
            
            print <<<EOF
            <tr bgcolor="$color">
                <td>
                    $c->name
                </td>
                <td align="center">
                    $c->score
                </td>
            </tr>
EOF;
        }
        print <<<EOF
        </table>
        <p>
        <hr>
        <form>
            <input type="hidden" name="mode" value="save">
            <input type="submit" value="BUZZ IN" style="height:200px; font-family:Arial,sans-serif; font-size:48pt; font-weight:bold; color:#FFFFFF; background-color:#FF0000;">
        </form>
        <p>
        <hr>
        <a href="?mode=refresh">Refresh</a>
        </div>
EOF;
    }
   
?>
