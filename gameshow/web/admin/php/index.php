<?php require_once 'common.php'; ?>
<html>
    <h1>Welcome</h1>
    <h2><?php print contestant_info() ?></h2>
    <br>
    <?php
        if ($_SESSION['name'])
        {
            print <<<EOF
            <a href="buzz.php">Buzzer Page</a>
            <br>
EOF;
        }
        else
        {
            print <<<EOF
            <a href="contestant_signup.php">Signup</a>
            <br>
EOF;
        }
    ?>
</html>
