# ddate
The discordian date.  Very similar to the venerable linux program.

It's just fun to have around. Elsewhere on my github, there are repositories with
versions in java, clojure, scala, lua, maybe one in Go... I can't remember.

I even did one as a Powershell module!  But this one is in swift since I'm on
macOS these days.


## Usage examples

    $ ddate
    Today is Prickle-Prickle, the 32nd day of The Aftermath in the YOLD 3188
    
    $ ddate tomorrow
    Setting Orange, The Aftermath 33, 3188 YOLD

    $ ddate yesterday
    Pungenday, The Aftermath 31, 3188 YOLD
    
    $ ddate 2020-6-30
    Sweetmorn, Confusion 35, 3186 YOLD
        
    $ ddate --help
    Usage: ddate [options]
    
    --date | -d  <Date>
       the date to present (defaults to today)
    --format | -f  <FmtString>
       describes how to format the date (see below)
    --help | -h
       displays this help text
    
    Format Strings: (e.g.,  "Today is %{%A, the %E of %B%}!")
      %A  weekday        /  %a  weekday (short version)
      %B  season         /  %b  season (short version)
      %d  day of season  /  %e  ordinal day of season
      %Y  the Year of Our Lady of Discord
      %X  the number of days left until X-Day
    
      %H  name of the holy day, if it is one
      %N  directive to skip the rest of the format
          if today is not a holy day
    
      %{ ... %}  either announce Tibs Day, or format the
                 interior string if it is not Tibs Day
    
      %n  newline        /  %t  tab
