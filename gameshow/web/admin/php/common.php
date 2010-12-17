<?php

    set_include_path(get_include_path().
                     PATH_SEPARATOR    .
                     "/home/ccaroon/codebase/common/lib/php");
    
    require_once 'MI/DBSession.php';
    require 'DB.php';

    $session_handler = new MI_DBSession(get_dbh());
    session_set_save_handler
        (
            array(&$session_handler, 'open'),
            array(&$session_handler, 'close'),
            array(&$session_handler, 'read'),
            array(&$session_handler, 'write'),
            array(&$session_handler, 'destroy'),
            array(&$session_handler, 'gc')
        );
    session_start();

    function signup_user()
    {
        if (!$_SESSION['name'])
        {
            header("Location: /~ccaroon/gameshow/php/contestant_signup.php");
            exit();
        }
    }

    ############################################################################
    function get_dbh()
    {
        $dbh = null;
        
        if ($GLOBALS['dbh'])
        {
            $dbh = $GLOBALS['dbh'];
        }
        else
        {
            $dbh = DB::connect('mysql://ccaroon:nu$@11@localhost/gameshow_db');
            
            if (DB::isError($dbh))
            {
                $dbh = null;
                die ("DB Connection Failed: ".$dbh->getMessage());
            }
            else
            {
                $dbh->setFetchMode(DB_FETCHMODE_OBJECT);
                $dbh->setErrorHandling(PEAR_ERROR_DIE);
            }
            
            $GLOBALS['dbh'] = $dbh;
        }

        return ($dbh);
    }
    ############################################################################
    function contestant_info()
    {
        $info = "";
        
        if ($_SESSION['name'])
        {
            $info = "<b>$_SESSION[name]</b>\n";
        }
        
        return ($info);
    }
    ############################################################################
    function get_next_question()
    {
        $dbh = get_dbh();
        
        $sql =<<<EOF
        select q.*
        from question q, question_queue qq
        where q.id = qq.question_id
        and q.used = 0
        order by qq.position
        limit 1
EOF;
        $question = $dbh->getRow($sql);
        
        return ($question);
    }
    

?>
