class Person
{
    has $.name;
    has $.age;

    method sing_a_song($about = 'Nothing')
    {
        say "La La La $about Da Da Da!";
    }
    
    
}
