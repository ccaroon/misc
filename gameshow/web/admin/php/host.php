<?php
    require_once 'common.php';
    
    
    if ($_REQUEST)
    {
        $mode = $_REQUEST['mode'];
        
        if ($mode == 'next_question')
        {
            _handle_next_question();
        }
        else if ($mode == 'update_score')
        {
            _handle_update_score();
        }
    }
    
    function _handle_update_score()
    {
        $dbh = get_dbh();
        
        $contestant_id = $_REQUEST['contestant_id'];
        $delta = $_REQUEST['delta_score'];
        
        $stmt = $dbh->prepare("update contestant set score = score$delta where id = $contestant_id");
        $dbh->execute($stmt);
    }
    
    function _handle_next_question()
    {
        $dbh = get_dbh();
        
        $stmt = $dbh->prepare("delete from buzz_in");
        $dbh->execute($stmt);
    }
    
    
    function _display_contestants()
    {
        $dbh  = get_dbh();
        
        $sql =<<<EOF
select * from
contestant c
order by c.name
EOF;
        $c_list = $dbh->getAll($sql);

        print <<<EOF
        <table border='1'>
            <tr>
EOF;
        foreach ($c_list as $c)
        {
            print <<<EOF
            <td>
                <table border="1">
                    <tr>
                        <td align="center" valign="middle"><h2>$c->name</h2></td>
                    </tr>
                    <tr>
                        <td align="center" valign="middle"><h3>$c->score</h3></td>
                    </tr>
                    <tr>
                        <td>
                            <form>
                                <input type="hidden" name="contestant_id" value="$c->id">
                                <input type="hidden" name="mode" value="update_score">
                                <input type="submit" name="delta_score" value="+10">
                                <input type="submit" name="delta_score" value="-10">
                                <input type="submit" name="delta_score" value="+5">
                                <input type="submit" name="delta_score" value="-5">
                            </form>
                        </td>
                    </tr>
                </table>
            </td>
EOF;
        }
        print <<<EOF
            </tr>
        </table>
EOF;
    }
    
?>
<html>
    <script language="javascript1.2">
    
        var req;
        
        function getTimeStr()
        {
            var date = new Date();
            
            var str = date.toString();
            
            return (str);
        }
        
        function getBody()
        {
            req = new XMLHttpRequest();
            req.onreadystatechange = updateBody;
            
            try
            {
                req.open("GET","/~ccaroon/gameshow/php/buzz_in_div.php",true);
                req.send(0);
            }
            catch (e)
            {
                updateBody(e);
                clearInterval(stopCode);
            }
        }
        
        function updateBody(body)
        {
            var body;
            
            if (req.readyState == 4)
            {
                if (req.status == 200)
                {
                    body = req.responseText;
                }
                else
                {
                    body = req.statusText;
                }
            }
            
            if (body)
            {
                div = document.getElementById("buzz_ins");
                div.innerHTML = "";
                div.innerHTML = body;
            }

        }
        
        var stopCode = setInterval(getBody, 1000);
        
        var timerStopCode;
        var seconds = 0;
        function startTimer()
        {
            if (seconds <= 0)
            {
                seconds = document.timer_form.minutes.value * 60;
            }
            
            if (timerStopCode == null)
            {
                timerStopCode = setInterval(displayTimer, 1000);
            }
        }
        
        function displayTimer()
        {
            if (seconds >= 0)
            {
                var timer_str = "<font size='9'>"+seconds+"</font>";
                div = document.getElementById("timer");
                div.innerHTML = "";
                div.innerHTML = timer_str;
                
                seconds--;
            }
        }
        
        function stopTimer()
        {
            clearInterval(timerStopCode);
            timerStopCode = null;
        }
        
        function resetTimer()
        {
            stopTimer();
            seconds = 0;
            displayTimer();
        }
        
    </script>
    <body>
        <div align="center" onLoad="getBody()">
        <table cellspacing="25">
            <tr>
                <td>
                    <?php print _display_contestants() ?>
                </td>
            </tr>
            <tr>
                <td align="center">
                    <div id="buzz_ins"></div>
                </td>
            </tr>
            <tr>
                <td align="center">
                    <form>
                        <input type="hidden" name="mode" value="next_question">
                        <input type="submit" value="Next Question" style="font-family:Arial,sans-serif; font-size:16pt; font-weight:bold; color:#000000;">
                    </form>
                </td>
            </tr>
        </table>
        <form name="timer_form">
            <table border="1">
                <tr>
                    <th colspan="3">Official Timer</th>
                </tr>
                <tr>
                    <td align="center">
                        <div id="timer">
                            <font size="9">000</font>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>
                        <b>Minutes: </b><input type="text" name="minutes" value="2" size="5">
                        <input type="button" name="" value="Start" onClick="startTimer()">
                        <input type="button" name="" value="Stop" onClick="stopTimer()">
                        <input type="button" name="" value="Reset" onClick="resetTimer()">
                    </td>
                </tr>
            </table>
        </form>
        <p>
            <textarea name="notes" style="font-size:12pt; font-weight:bold" rows="10" cols="50"></textarea>
        <p>
        <a href="?">Refresh</a>
        </div>
    </body>
</html>
