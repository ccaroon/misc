<?php
    require_once 'common.php';


    function display_buzz_ins()
    {
        $dbh  = get_dbh();
        
        $sql =<<<EOF
select * from
buzz_in b,
contestant c
where b.contestant_id = c.id
order by b.buzz_in_date
EOF;
        $buzz_q = $dbh->getAll($sql);
        
        if (count($buzz_q) < 1)
        {
            print '<font size="7" color="red"><blink>Waiting...</blink></font>';
        }
        else
        {
            print <<<EOF
        <table border='1' width="75%">
            <tr>
                <th>Name</th>
                <th>Score</th>
            </tr>
EOF;
            $color = "lightgreen";
            foreach ($buzz_q as $c)
            {           
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
                $color = "white";
            }
        print <<<EOF
        </table>
EOF;
        }
    }

    print display_buzz_ins();
?>
