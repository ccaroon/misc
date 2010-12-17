<?php
    require_once 'common.php';
    
    if ($_POST)
    {
        $dbh = get_dbh();
        
        $stmt = $dbh->prepare("insert into contestant (name) values (?)");
        
        $data = array($_POST['name']);
        
        $dbh->execute($stmt, $data);
        $id  =& $dbh->getOne("select LAST_INSERT_ID()");
        
        $_SESSION['id']   = $id;
        $_SESSION['name'] = $_POST['name'];
        $_SESSION['score'] = 0;
        header("Location: /~ccaroon/gameshow/php/index.php");
    }
    else
    {
        $dbh = get_dbh();
        $all_cont = $dbh->getAll("select * from contestant");
        
        $curr_cont_html;
        foreach ($all_cont as $c)
        {
            $curr_cont_html .= $c->name."<br>\n";
        }
        
        print <<<EOF
<html>
    <div align="center">
        <h1>Contestant Signup</h1>
        <hr>
        <form method="POST">
            <b>Name:</b> <input type='text' name='name'><br>
            <p>
            <input type='submit' value='Signup'>
            <p>
            <hr>
            <b>Currently Signed-up</b>
            <p>
            $curr_cont_html
        </form>
    </div>
</html>
EOF;
    }
?>
